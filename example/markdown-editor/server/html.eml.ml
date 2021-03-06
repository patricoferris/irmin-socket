let html = 
  <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>OCaml x Mithril</title>
      <script src="https://unpkg.com/mithril/mithril.js"></script>
      <style>
        @import url('https://rsms.me/inter/inter.css');

        html {
          font-family: 'Inter', sans-serif;
          background-color: #121212;
          color: #fffff7;
        }

        @supports (font-variation-settings: normal) {
          html {
            font-family: 'Inter var', sans-serif;
            background-color: #121212;
            color: #fffff7;
          }
        }

        main {
          display: flex;
        }

        div.text-editor {
          font-family: 'Courier New', Courier, monospace;
          height: 100%;
          min-height: 90vh;
          width: 45%;
          border: solid;
          border-width: 1px;
          padding: 15px;
          white-space: pre;
        }

        div.markdown {
          height: 100%;
          min-height: 90vh;
          flex-grow: 1;
          padding-left: 15px;
        }
      </style>
    </head>
    <body>
      <script src="/static/index.js"></script>
    </body>
  </html>