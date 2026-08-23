# Oryol Fit

Trainings-Journal für Kraft und Cardio. Gebaut wie Oryol: eine einzige
`index.html`, kein Build-Schritt, PWA fürs Handy, Abgleich über dein eigenes
Supabase-Projekt.

## Dateien

| Datei | Zweck |
|---|---|
| `index.html` | die gesamte App |
| `manifest.json` | macht sie am Handy zur App |
| `icon-*.png`, `favicon.png`, `apple-touch-icon.png` | Symbole |
| `supabase.sql` | die eine Tabelle für den Abgleich |

Alle Dateien gehören in denselben Ordner. Chart.js wird wie in Oryol von
cdnjs nachgeladen — sonst gibt es keine externen Abhängigkeiten.

## In Betrieb nehmen

1. **Hochladen.** Ordner auf denselben Weg bringen wie Oryol (Railway,
   Netlify, Vercel, GitHub Pages — alles, was statische Dateien über HTTPS
   ausliefert). HTTPS ist Pflicht, sonst gibt es kein „Zum Home-Bildschirm".

2. **Supabase.** Neues kostenloses Projekt anlegen, im SQL-Editor den Inhalt
   von `supabase.sql` ausführen. Danach unter *Project Settings → API* die
   **Project URL** und den **anon public key** kopieren.

3. **Verbinden.** In der App: *Daten → Einstellungen → Synchronisation*.
   URL und Key eintragen, bei der Journal-Kennung auf „Zufällig" tippen.
   Auf dem zweiten Gerät exakt dieselben drei Werte eintragen — fertig.

4. **Aufs Handy.** Seite in Safari öffnen → Teilen → *Zum Home-Bildschirm*.
   In Chrome/Android erscheint die Installationsaufforderung von selbst.

## Aufbau

Zweistufige Navigation wie in Oryol: Gruppen oben, Tabs darunter, jede
Ansicht ist eine `<section id="v-…">`.

| Gruppe | Ansichten |
|---|---|
| **Training** | Dashboard · Training eintragen · Verlauf · Cardio · Übungen |
| **Planung** | Vorlagen & Wochenplan · Kalender · Ziele · Rückblick |
| **Auswertung** | Volumen · Progression · Belastung · Rechner |
| **Daten** | Körper · Einstellungen |

Ein globales `S`-Objekt hält den Zustand, `renderAll()` zeichnet alles neu,
`put(sammlung, objekt)` schreibt und stößt den Abgleich an. Dieselbe
Mechanik wie im Trading-Journal.

## Unterschied beim Abgleich

Bei Oryol kommen die Trades von der Börsen-API — jedes Gerät holt sie sich
selbst, deshalb reisen dort nur die Notizen. Hier gibt es keine externe
Quelle: jede Wiederholung ist Handeingabe. Also tragen die Zeilen die
echten Daten. Der Mechanismus bleibt gleich: eine Tabelle, Upsert mit
`on_conflict`, bei Konflikten gewinnt der neuere Zeitstempel, gelöschte
Einträge bleiben als Grabstein stehen, damit das Löschen auch auf einem
lange nicht benutzten Gerät ankommt.

Gesendet wird entprellt 1,2 Sekunden nach jeder Änderung, dazu beim Öffnen
und beim Zurückwechseln zur App.

## Was drinsteckt

**Krafttraining** — 63 Standardübungen mit Muskelgruppe und Gerät, eigene
Übungen jederzeit ergänzbar. Satzweise Eingabe mit Gewicht und
Wiederholungen; die letzte Ausführung derselben Übung steht direkt über den
Feldern. Aufwärmsätze zählen nicht ins Volumen. Bestleistungen werden
automatisch erkannt und nach dem Training gemeldet.

**RIR und Satztyp liegen im Datenmodell**, sind aber ab Werk ausgeblendet,
damit die Eingabe im Studio schnell bleibt. Beide lassen sich in den
Einstellungen einschalten — ohne Migration, ohne Datenverlust.

**Cardio** — Art, Dauer, Distanz, Puls, Anstrengung. Daraus Tempo,
Zeit je Herzfrequenz-Zone und die aerobe Effizienz: Geschwindigkeit je
Pulsschlag über die Zeit. Das ist die Kurve, die zeigt, ob die Grundlage
wirklich wächst.

**Planung** — Vorlagen mit Zielsätzen, Zielwiederholungen und
Progressionsregel; daraus schlägt die App beim Start das nächste Gewicht
vor (doppelte Progression: erst Wiederholungen bis zum Ziel, dann Gewicht).
Wochenplan, Trainingsblock mit Deload-Woche, und der Soll-Ist-Abgleich mit
Planquote — das Gegenstück zu „Regel eingehalten" im Trading-Journal.

**Auswertung** — Arbeitssätze pro Muskelgruppe mit den Richtwerten aus der
Trainingslehre (Minimum, guter Bereich, obere Grenze; Nebenmuskeln zählen
halb), Progressionskurven je Übung über geschätztes 1RM, Balance-Prüfungen
(Drücken gegen Ziehen, Quadrizeps gegen Beinbeuger), Konsistenz-Heatmap und
das Verhältnis der letzten 7 Tage zum Schnitt der letzten 28 — die Kennzahl,
an der sich Überlastung früh ablesen lässt.

**Körperdaten** — Gewicht mit gleitendem Sieben-Tage-Schnitt, Körperfett,
Umfänge. Das im Training eingetragene Körpergewicht wandert automatisch
hierher.

## Sicherung

*Daten → Einstellungen → Sicherungskopie* schreibt alles in eine
JSON-Datei. Das Einlesen führt zusammen statt zu überschreiben: bei
gleicher Kennung gewinnt auch hier der neuere Zeitstempel.
