import gleam/fetch
import gleam/http/request
import gleam/http/response
import gleam/int
import gleam/javascript/promise.{type Promise}
import gleam/list
import gleam/result
import gleam/string
import gleam/uri
import glogg/handler
import glogg/level
import glogg/logger
import hinoto
import hinoto/body.{type Body}
import hinoto/runtime/workers

/// Converts an emoji to a twemoji SVG URL.
///
/// Accepts URL-encoded strings. When given multiple emoji,
/// only the first character is used.
pub fn emoji2url(str: String) -> Result(String, Nil) {
  use emoji <- result.try(uri.percent_decode(str))
  use codepoint <- result.try(
    string.to_utf_codepoints(emoji)
    |> list.map(fn(ch) {
      string.utf_codepoint_to_int(ch)
      |> int.to_base16
      |> string.lowercase
    })
    |> list.first,
  )
  Ok(
    "https://cdn.jsdelivr.net/gh/twitter/twemoji@latest/assets/svg/"
    <> codepoint
    <> ".svg",
  )
}

/// Fetches the SVG from the URL and reads the response body as text.
///
/// Returns `Error` on network failure or invalid URL.
pub fn fetch_svg(
  url: String,
) -> Promise(Result(response.Response(String), fetch.FetchError)) {
  case request.to(url) {
    Ok(req) ->
      fetch.send(req)
      |> promise.try_await(fetch.read_text_body)
    Error(_) -> promise.resolve(Error(fetch.NetworkError("Invalid URL")))
  }
}

/// Builds a response with the given status, body, and Content-Type.
fn text_response(
  status: Int,
  body: String,
  content_type: String,
) -> response.Response(Body) {
  response.new(status)
  |> response.set_body(body.StringBody(body))
  |> response.set_header("content-type", content_type)
}

/// Returns the given SVG string as a 200 OK response.
///
/// Sets a long `Cache-Control` so the Worker response can be cached by
/// Workers Cache at the edge.
pub fn return_svg(svg: String) -> response.Response(Body) {
  text_response(200, svg, "image/svg+xml")
  |> response.set_header(
    "cache-control",
    "public, max-age=604800, s-maxage=604800",
  )
}

/// Returns a 500 Internal Server Error response.
pub fn internal_server_error() -> response.Response(Body) {
  text_response(500, "Error", "text/plain")
}

/// Returns a 404 Not Found response.
pub fn not_found() -> response.Response(Body) {
  text_response(404, "not found", "text/html")
}

/// Handler for the `/api/<emoji>` route.
///
/// Converts the emoji to SVG and returns it. Returns 500 on
/// conversion or fetch failure.
pub fn emoji_api(str: String) -> Promise(response.Response(Body)) {
  case emoji2url(str) {
    Ok(url) ->
      fetch_svg(url)
      |> promise.map(fn(result) {
        case result {
          Ok(resp) -> return_svg(resp.body)
          Error(_) -> internal_server_error()
        }
      })
    Error(_) -> promise.resolve(internal_server_error())
  }
}

/// Cloudflare Workers entry point.
///
/// Routes `/api/<emoji>` to the SVG converter, everything else to 404.
pub fn main() {
  handler.set_default_handler_minimum_level(level.Info)

  let log = logger.new("emoji2svg")

  workers.serve(fn(hinoto) {
    use hinoto <- promise.await(
      hinoto
      |> hinoto.handle(fn(req) {
        case request.path_segments(req) {
          ["api", str] -> {
            let emoji = case uri.percent_decode(str) {
              Ok(decoded) -> decoded
              Error(_) -> str
            }

            log
            |> logger.info("emoji request: " <> emoji, [
              logger.string("emoji", emoji),
            ])

            emoji_api(str)
          }
          _ -> {
            log
            |> logger.warning("not found", [
              logger.string("path", req.path),
            ])

            not_found()
            |> promise.resolve
          }
        }
      }),
    )
    promise.resolve(hinoto)
  })
}
