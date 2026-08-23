-- ===========================================================================
--  Oryol Fit — Tabelle für die Synchronisation
--
--  Einmal im SQL-Editor deines Supabase-Projekts ausführen.
--  Danach in der App unter Daten → Einstellungen → Synchronisation
--  Projekt-URL, Anon-Key und eine frei gewählte Journal-Kennung eintragen.
--  Auf dem zweiten Gerät exakt dieselben drei Werte eintragen.
--
--  Unterschied zum Trading-Journal: dort kommen die Trades von der Börsen-API,
--  deshalb reisen nur Notizen. Hier gibt es keine externe Quelle — jede
--  Wiederholung ist Handeingabe. Also tragen die Zeilen die echten Daten.
--  Der Abgleich bleibt derselbe: neuerer Zeitstempel gewinnt.
-- ===========================================================================

create table if not exists public.fit_rows (
  journal_id  text        not null,
  item_id     text        not null,
  kind        text        not null,          -- ex | ses | car | tpl | goal | body | rev | meta
  payload     jsonb,
  deleted     boolean     not null default false,
  updated_at  bigint      not null,          -- Millisekunden seit 1970
  primary key (journal_id, item_id)
);

create index if not exists fit_rows_journal_idx on public.fit_rows (journal_id);
create index if not exists fit_rows_updated_idx on public.fit_rows (journal_id, updated_at);

-- ---------------------------------------------------------------------------
--  Zugriff
--
--  Die App meldet sich mit dem öffentlichen Anon-Key an — genau wie das
--  Trading-Journal. Der Schutz liegt darin, dass niemand deine Journal-Kennung
--  kennt. Wähle sie entsprechend: lang und nicht zu erraten. Der Knopf
--  „Zufällig" in der App erzeugt eine passende.
--
--  Wer es strenger will, legt stattdessen eine echte Anmeldung an und
--  ersetzt die Regel unten durch eine, die auf auth.uid() prüft.
-- ---------------------------------------------------------------------------

alter table public.fit_rows enable row level security;

drop policy if exists "fit_rows_anon_all" on public.fit_rows;
create policy "fit_rows_anon_all"
  on public.fit_rows
  for all
  to anon
  using (true)
  with check (true);

-- ---------------------------------------------------------------------------
--  Aufräumen: endgültig gelöschte Einträge nach einem Jahr entfernen.
--  Optional — die Grabsteine sind winzig und sorgen dafür, dass ein
--  Löschen auch auf einem lange nicht benutzten Gerät ankommt.
-- ---------------------------------------------------------------------------

-- delete from public.fit_rows
--  where deleted = true
--    and updated_at < (extract(epoch from now()) * 1000 - 365 * 86400000);
