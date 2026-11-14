import os
from flask import Flask, make_response, render_template
import pymysql
from werkzeug.middleware.proxy_fix import ProxyFix

app = Flask(__name__)

# Nginx-välityspalvelimen tuki
app.wsgi_app = ProxyFix(app.wsgi_app, x_for=1, x_proto=1, x_prefix=1)


def get_db_connection():
  return pymysql.connect(
      unix_socket="/run/mysqld/mysqld.sock",
      user="viikko2app",
      password="*23AE809DDACAF96AF0FD78ED04B6A265E05AA257",  # Aseta salasanasi tähän suoraan varmuuden vuoksi
      database="Week2",
      charset="utf8mb4",
      cursorclass=pymysql.cursors.DictCursor,
  )


def alusta_tietokanta():
  """Varmistaa, että laskuritaulu ja ensimmäinen rivi on olemassa."""
  try:
    conn = get_db_connection()
    with conn.cursor() as cursor:
      cursor.execute("""
                CREATE TABLE IF NOT EXISTS laskuri (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    kaynnit INT NOT NULL DEFAULT 0
                )
            """)
      cursor.execute("SELECT kaynnit FROM laskuri WHERE id = 1")
      if not cursor.fetchone():
        cursor.execute("INSERT INTO laskuri (id, kaynnit) VALUES (1, 0)")
      conn.commit()
    conn.close()
  except Exception as e:
    print(f"Tietokannan alustusvirhe: {e}")


# Ajetaan alustus heti kun sovellus käynnistyy
alusta_tietokanta()


def kasvata_laskuria():
  conn = get_db_connection()
  try:
    with conn.cursor() as kursori:
      kursori.execute("UPDATE laskuri SET kaynnit = kaynnit + 1 WHERE id = 1")
      kursori.execute("SELECT kaynnit FROM laskuri WHERE id = 1")
      tulos = kursori.fetchone()
      kaynnit = tulos["kaynnit"] if tulos else 1
      conn.commit()
      return kaynnit
  except Exception:
    conn.rollback()
    raise
  finally:
    conn.close()


@app.route("/")
def etusivu():
  kaynnit = kasvata_laskuria()
  vastaus = make_response(render_template("index.html", kaynnit=kaynnit))
  vastaus.headers["Cache-Control"] = "no-store"
  return vastaus


if __name__ == "__main__":
  app.run(host="0.0.0.0", port=5000, debug=True)
