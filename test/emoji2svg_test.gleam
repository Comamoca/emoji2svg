import emoji2svg
import gleam/http/response
import gleeunit
import hinoto/body

pub fn main() -> Nil {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn hello_world_test() {
  let name = "Joe"
  let greeting = "Hello, " <> name <> "!"

  assert greeting == "Hello, Joe!"
}

pub fn emoji2svg_test() {
  let emoji = "🍣"
  let expect =
    "https://cdn.jsdelivr.net/gh/twitter/twemoji@latest/assets/svg/1f363.svg"
  let assert Ok(actual) = emoji2svg.emoji2url(emoji)

  assert actual == expect
}

// TODO: URLエンコードされた文字列のテストもする
pub fn emoji2svg_url_decode_test() {
  let emoji = "%F0%9F%8D%A3"
  let expect =
    "https://cdn.jsdelivr.net/gh/twitter/twemoji@latest/assets/svg/1f363.svg"
  let assert Ok(actual) = emoji2svg.emoji2url(emoji)
  assert actual == expect
}

pub fn emoji2url_empty_string_test() {
  let assert Error(_) = emoji2svg.emoji2url("")
}

pub fn emoji2url_invalid_encoding_test() {
  let assert Error(_) = emoji2svg.emoji2url("%ZZ")
}

pub fn emoji2url_multi_emoji_test() {
  // 複数絵文字は最初の1文字だけが使われる
  let emoji = "🍣🍜"
  let expect =
    "https://cdn.jsdelivr.net/gh/twitter/twemoji@latest/assets/svg/1f363.svg"
  let assert Ok(actual) = emoji2svg.emoji2url(emoji)
  assert actual == expect
}

pub fn return_svg_test() {
  let resp = emoji2svg.return_svg("<svg></svg>")

  assert resp.status == 200
  assert response.get_header(resp, "content-type") == Ok("image/svg+xml")
  assert resp.body == body.StringBody("<svg></svg>")
}

pub fn internal_server_error_test() {
  let resp = emoji2svg.internal_server_error()

  assert resp.status == 500
  assert resp.body == body.StringBody("Error")
}

pub fn not_found_test() {
  let resp = emoji2svg.not_found()

  assert resp.status == 404
  assert response.get_header(resp, "content-type") == Ok("text/html")
  assert resp.body == body.StringBody("not found")
}
