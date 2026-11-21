import email.utils
import html
import json
import os
import re
import time
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET
import zlib
from datetime import datetime, timedelta, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONFIG = Path(__file__).resolve().parent / "planets.json"
OUT = ROOT / "news_data"
MODEL = "gemini-3.5-flash-lite"
GDELT = "https://api.gdeltproject.org/api/v2/doc/doc"
GOOGLE_RSS = "https://news.google.com/rss/search"
BING_RSS = "https://www.bing.com/news/search"
GEMINI = "https://generativelanguage.googleapis.com/v1beta/models/"
USER_AGENT = "DreamWorldNewsBot/1.0 (daily news generator)"
TIMEOUT = 12


def request(url, timeout=TIMEOUT):
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(req, timeout=timeout) as response:
        return response.read().decode("utf-8", "replace")


def request_json(url, timeout=TIMEOUT):
    return json.loads(request(url, timeout))


def now_iso():
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


def iso_from_gdelt(value):
    try:
        parsed = datetime.strptime(value, "%Y%m%dT%H%M%SZ")
        return parsed.replace(tzinfo=timezone.utc).isoformat().replace("+00:00", "Z")
    except (ValueError, TypeError):
        return now_iso()


def iso_from_rss(value):
    try:
        parsed = email.utils.parsedate_to_datetime(value)
        if parsed.tzinfo is None:
            parsed = parsed.replace(tzinfo=timezone.utc)
        return parsed.astimezone(timezone.utc).isoformat().replace("+00:00", "Z")
    except (TypeError, ValueError, IndexError):
        return now_iso()


def clean(value):
    return re.sub(r"\s+", " ", html.unescape(value or "")).strip()


def shorten(value, limit):
    value = clean(str(value))
    return value if len(value) <= limit else value[: limit - 1].rstrip() + "…"


def fetch_gdelt(query):
    params = urllib.parse.urlencode(
        {
            "query": f"{query} sourcelang:russian",
            "mode": "artlist",
            "maxrecords": 25,
            "timespan": "1d",
            "sort": "datedesc",
            "format": "json",
        }
    )
    for attempt in range(2):
        try:
            data = request_json(f"{GDELT}?{params}")
            articles = []
            for item in data.get("articles") or []:
                title = clean(item.get("title"))
                url = item.get("url") or ""
                if not title or not url:
                    continue
                articles.append(
                    {
                        "title": title,
                        "url": url,
                        "source": item.get("domain") or "Источник",
                        "publishedAt": iso_from_gdelt(item.get("seendate")),
                    }
                )
            return articles
        except Exception as error:
            text = str(error).lower()
            if "429" in text or "limit" in text:
                time.sleep(6)
                continue
            return []
    return []


def parse_rss(xml_text, source_fix=None):
    try:
        root = ET.fromstring(xml_text)
    except Exception:
        return []
    articles = []
    for item in root.findall(".//item"):
        title = clean(item.findtext("title"))
        url = clean(item.findtext("link"))
        if not title or not url:
            continue
        if source_fix:
            url, source = source_fix(url, item)
        else:
            source_node = item.find("source")
            source = clean(source_node.text if source_node is not None else "Источник")
        articles.append(
            {
                "title": title,
                "url": url,
                "source": source or "Источник",
                "publishedAt": iso_from_rss(item.findtext("pubDate")),
            }
        )
    return articles


def fetch_google_rss(query):
    params = urllib.parse.urlencode(
        {"q": f"{query} when:1d", "hl": "ru", "gl": "RU", "ceid": "RU:ru"}
    )
    try:
        return parse_rss(request(f"{GOOGLE_RSS}?{params}"))
    except Exception:
        return []


def bing_source_fix(url, item):
    parsed = urllib.parse.urlparse(url)
    values = urllib.parse.parse_qs(parsed.query)
    original = values.get("url", [url])[0]
    source_node = item.find("{https://www.bing.com/news/search}Source")
    if source_node is None:
        source_node = next(
            (node for node in item if node.tag.endswith("Source")), None
        )
    source = clean(source_node.text if source_node is not None else "Источник")
    return original, source


def fetch_bing_rss(query):
    params = urllib.parse.urlencode({"q": query, "format": "rss", "mkt": "ru-RU"})
    try:
        return parse_rss(request(f"{BING_RSS}?{params}"), bing_source_fix)
    except Exception:
        return []


def title_tokens(title):
    return {
        token
        for token in re.findall(r"[a-zа-яё0-9]+", clean(title).lower())
        if len(token) > 3
    }


def is_relevant(planet, article):
    title = clean(article.get("title"))
    if not title:
        return False
    if any(re.search(pattern, title, re.IGNORECASE) for pattern in planet.get("reject", [])):
        return False
    return any(re.search(pattern, title, re.IGNORECASE) for pattern in planet.get("require", []))


def merge_articles(current, incoming):
    seen = {item["url"] for item in current}
    signatures = [title_tokens(item["title"]) for item in current]
    result = list(current)
    for item in incoming:
        if item["url"] in seen:
            continue
        tokens = title_tokens(item["title"])
        if tokens and any(
            len(tokens & other) / len(tokens | other) >= 0.72 for other in signatures
        ):
            continue
        seen.add(item["url"])
        signatures.append(tokens)
        result.append(item)
    return result


def article_time(article):
    try:
        return datetime.fromisoformat(
            article["publishedAt"].replace("Z", "+00:00")
        )
    except (ValueError, KeyError, AttributeError):
        return datetime.min.replace(tzinfo=timezone.utc)


def sort_and_filter(articles):
    articles.sort(key=article_time, reverse=True)
    threshold = datetime.now(timezone.utc) - timedelta(days=30)
    fresh = [item for item in articles if article_time(item) >= threshold]
    return fresh if len(fresh) >= 3 else articles


def collect(planet):
    queries = planet.get("queries") or [planet["query"]]
    articles = []
    used = []
    gdelt = [item for item in fetch_gdelt(planet["query"]) if is_relevant(planet, item)]
    if gdelt:
        used.append("gdelt")
        articles = merge_articles(articles, gdelt)
    for fetcher, label in ((fetch_google_rss, "google-rss"), (fetch_bing_rss, "bing-rss")):
        for query in queries:
            if len(articles) >= 5:
                break
            incoming = fetcher(query)
            accepted = [item for item in incoming if is_relevant(planet, item)]
            if accepted:
                if label not in used:
                    used.append(label)
                articles = merge_articles(articles, accepted)
    return sort_and_filter(articles)[:5], "+".join(used) or "rss"


def gemini_rewrite(planet, articles, key):
    payload = json.dumps(
        {
            "planet": planet["name"],
            "style": planet["style"],
            "tag": planet["keywords"][0] if planet["keywords"] else "Новости",
            "articles": articles,
        },
        ensure_ascii=False,
    )
    body = {
        "contents": [
            {
                "role": "user",
                "parts": [
                    {
                        "text": (
                            "Ты редактор ленты сообщества Dream World. "
                            "Напиши по одной короткой новости на русском языке для каждого переданного материала. "
                            "В заголовке до 80 символов, в резюме до 180 символов. "
                            "Сохраняй смысл исходного заголовка, не выдумывай факты и не копируй текст полностью. "
                            "Выдерживай стиль планеты. Верни только JSON-массив без обёртки, "
                            "где у каждого элемента есть поля title, summary, emoji, tag, likes. "
                            "likes — целое число от 3 до 120. "
                            "Порядок элементов должен совпадать с порядком материалов. "
                            "Данные: " + payload
                        )
                    }
                ],
            }
        ],
        "generationConfig": {
            "temperature": 0.7,
            "responseMimeType": "application/json",
            "maxOutputTokens": 2048,
        },
    }
    req = urllib.request.Request(
        f"{GEMINI}{MODEL}:generateContent",
        data=json.dumps(body).encode("utf-8"),
        headers={
            "Content-Type": "application/json",
            "X-goog-api-key": key,
            "User-Agent": USER_AGENT,
        },
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=60) as response:
        data = json.loads(response.read().decode("utf-8"))
    text = data["candidates"][0]["content"]["parts"][0]["text"]
    items = json.loads(text)
    if isinstance(items, dict):
        items = items.get("news") or items.get("items") or []
    return items if isinstance(items, list) else []


def template_rewrite(planet, articles):
    tag = planet["keywords"][0] if planet["keywords"] else "Новости"
    style = planet["style"]
    lead = style[0].upper() + style[1:]
    result = []
    for article in articles:
        seed = zlib.crc32(f"{planet['id']}:{article['url']}".encode("utf-8"))
        result.append(
            {
                "title": shorten(article["title"], 100),
                "summary": shorten(f"{lead}. Источник: {article['source']}.", 190),
                "emoji": planet["emoji"],
                "tag": tag,
                "likes": 3 + seed % 90,
            }
        )
    return result


def build_news(planet, articles, key, mode):
    generated = []
    if key:
        try:
            generated = gemini_rewrite(planet, articles, key)
        except Exception as error:
            print(f"Gemini недоступен для {planet['id']}: {error}", flush=True)
    items = generated if len(generated) == len(articles) else template_rewrite(planet, articles)
    actual_mode = "gemini" if items is generated and key else mode
    news = []
    seen = set()
    for index, article in enumerate(articles):
        if article["url"] in seen:
            continue
        seen.add(article["url"])
        rewritten = items[index] if index < len(items) else {}
        fallback = template_rewrite(planet, [article])[0]
        title = shorten(rewritten.get("title") or article["title"], 120)
        if not is_relevant(planet, {"title": title}):
            title = shorten(article["title"], 120)
        news.append(
            {
                "id": f"{planet['id']}_news_{zlib.crc32(article['url'].encode('utf-8'))}",
                "title": title,
                "summary": shorten(rewritten.get("summary") or fallback["summary"], 260),
                "emoji": shorten(rewritten.get("emoji") or planet["emoji"], 8),
                "sourceName": shorten(article["source"], 60),
                "sourceUrl": article["url"],
                "tag": shorten(rewritten.get("tag") or fallback["tag"], 32),
                "publishedAt": article["publishedAt"],
                "likes": int(rewritten.get("likes") or fallback["likes"]),
            }
        )
    return news, actual_mode


def main():
    planets = json.loads(CONFIG.read_text(encoding="utf-8"))
    key = os.environ.get("GEMINI_API_KEY", "").strip()
    OUT.mkdir(parents=True, exist_ok=True)
    generated_at = now_iso()
    total = 0
    modes = set()
    sources = set()
    for index, planet in enumerate(planets):
        if index:
            time.sleep(5.5)
        articles, source = collect(planet)
        news, mode = build_news(planet, articles, key, "template")
        path = OUT / f"{planet['id']}.json"
        if not news and path.exists():
            previous = json.loads(path.read_text(encoding="utf-8"))
            items = previous.get("news") or []
            if len(items) >= 3 and all(
                is_relevant(planet, {"title": item.get("title", "")}) for item in items
            ):
                print(f"{planet['id']}: сохранён предыдущий релевантный выпуск", flush=True)
                total += len(items)
                modes.add(previous.get("mode") or mode)
                sources.add(previous.get("source") or source)
                continue
        if not news:
            print(f"{planet['id']}: нет релевантных материалов, выпуск пуст", flush=True)
            source = "none"
        payload = {
            "planetId": planet["id"],
            "updatedAt": generated_at,
            "source": source,
            "mode": mode,
            "news": news,
        }
        path.write_text(
            json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )
        total += len(news)
        modes.add(mode)
        sources.add(source)
        print(
            f"{planet['id']}: {len(news)} новостей, источник {source}, режим {mode}",
            flush=True,
        )
    manifest = {
        "generatedAt": generated_at,
        "planets": len(planets),
        "news": total,
        "modes": sorted(modes),
        "sources": sorted(sources),
    }
    (OUT / "manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(json.dumps(manifest, ensure_ascii=False), flush=True)


if __name__ == "__main__":
    main()
