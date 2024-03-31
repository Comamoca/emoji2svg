<div align="center">

![Last commit](https://img.shields.io/github/last-commit/Comamoca/baserepo?style=flat-square)
![Repository Stars](https://img.shields.io/github/stars/Comamoca/baserepo?style=flat-square)
![Issues](https://img.shields.io/github/issues/Comamoca/baserepo?style=flat-square)
![Open Issues](https://img.shields.io/github/issues-raw/Comamoca/baserepo?style=flat-square)
![Bug Issues](https://img.shields.io/github/issues/Comamoca/baserepo/bug?style=flat-square)

<img src="https://emoji2svg.deno.dev/api/🍣" alt="eyecatch" height="100">

# emoji2svg
絵文字をSVGに変換するAPIです🍣

<br>
<br>

</div>

<table>
  <thead>
    <tr>
      <th style="text-align:center">🍡日本語</th>
      <th style="text-align:center"><a href="README.md">🍔English</a></th>
    </tr>
  </thead>
</table>

<div align="center">

</div>

## 🚀 使い方

Sentryのアカウントをお持ちの場合はSentryによるエラー追跡を利用できます。
環境変数`SENTRY_DSN`にSentryのDSNをセットしてください。

```
curl https://emoji2svg.deno.dev/api/🦊
```

## ⛏️   開発

```sh
deno task run
```

## 📝 Todo

- [ ] Allow size selection

## 📜 ライセンス

MIT

### 🧩 Modules

- [Hono](https://hono.dev)
- [twemoji-parser](https://github.com/twitter/twemoji-parser)

## 👏 影響を受けたプロジェクト

[URLで絵文字を指定したらTwemoji画像を返す仕組みを作った by Cloud Functions](https://zenn.dev/team_zenn/articles/5b331a95a6f6f5)
