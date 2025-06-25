# 🏢 Property & Project Manager

Ein umfassendes Immobilienverwaltungssystem für Vermieter und Eigennutzer.

## 🚀 Features

- **Aufgabenverwaltung** mit Prioritäten, Fristen und Wiederholungen
- **Kanban-Board** mit Drag & Drop
- **Projektverwaltung** mit Meilensteinen und Budgettracking
- **Dienstleister-Datenbank** für Handwerker und Service-Anbieter
- **Budget-Übersicht** pro Gebäude
- **Umfangreiches Wiki** mit Verkehrssicherungspflichten
- **Offline-fähig** als Progressive Web App
- **Datenexport** für Backups

## 📦 Installation

### Option 1: Lokale Nutzung
```bash
# Repository klonen
git clone https://github.com/Gnadulf/ppmanager.git
cd ppmanager

# Im Browser öffnen
open index.html
```

### Option 2: Web-Deployment

#### Netlify (Empfohlen)
[![Deploy to Netlify](https://www.netlify.com/img/deploy/button.svg)](https://app.netlify.com/start/deploy?repository=https://github.com/Gnadulf/ppmanager)

1. Button klicken
2. GitHub verbinden
3. Automatisch deployen

#### Vercel
[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/Gnadulf/ppmanager)

#### GitHub Pages
```bash
# In Repository Settings
# Pages > Source: main branch
# URL: https://Gnadulf.github.io/ppmanager
```

### Option 3: Docker
```bash
# Build und Start
docker-compose up -d

# App öffnen
open http://localhost:8080
```

## 🔧 Konfiguration

### Gebäude anpassen
Bearbeiten Sie die Gebäudeliste in `index.html`:
```javascript
<option value="KDW17">KDW17</option>
<option value="Ihre-Immobilie">Ihre Immobilie</option>
```

### Supabase Integration (Optional)
1. Supabase Projekt erstellen
2. `.env` Datei erstellen:
```bash
cp .env.example .env
# Credentials eintragen
```
3. Datenbank-Schema ausführen (siehe `supabase-schema.sql`)

## 📱 Mobile Installation

### iOS
1. Safari öffnen
2. Website aufrufen
3. Teilen → "Zum Home-Bildschirm"

### Android
1. Chrome öffnen
2. Website aufrufen
3. Menü → "App installieren"

## 🛡️ Datensicherheit

- Daten werden lokal im Browser gespeichert
- Keine Übertragung ohne explizite Cloud-Sync
- Regelmäßige Backups über Export-Funktion
- Optional: Verschlüsselte Supabase-Synchronisation

## 🔄 Updates

### Automatische Updates (PWA)
Der Service Worker aktualisiert die App automatisch im Hintergrund.

### Manuelle Updates
```bash
git pull origin main
# Browser-Cache leeren (Ctrl+Shift+R)
```

## 📊 Datenstruktur

### Aufgaben
```javascript
{
  id: timestamp,
  title: "Aufgabentitel",
  building: "Gebäude",
  priority: "hoch|mittel|niedrig",
  deadline: "YYYY-MM-DD",
  recurrence: "daily|weekly|8weeks|16weeks|yearly",
  contractor: contractorId,
  budget: 0.00,
  stakeholders: ["email@example.com"],
  description: "Beschreibung",
  completed: false,
  status: "todo|progress|done"
}
```

### Projekte
```javascript
{
  id: timestamp,
  title: "Projekttitel",
  building: "Gebäude",
  status: "planning|active|completed",
  startDate: "YYYY-MM-DD",
  endDate: "YYYY-MM-DD",
  budget: 0.00,
  milestones: [
    {
      date: "YYYY-MM-DD",
      text: "Meilenstein",
      done: false
    }
  ],
  description: "Beschreibung"
}
```

## 🤝 Support

- **Dokumentation**: [Wiki](https://github.com/yourusername/property-manager/wiki)
- **Issues**: [GitHub Issues](https://github.com/yourusername/property-manager/issues)
- **Diskussionen**: [GitHub Discussions](https://github.com/yourusername/property-manager/discussions)

## 📄 Lizenz

MIT License - siehe [LICENSE](LICENSE) Datei

## 🙏 Credits

- Icons: Emoji
- Framework: Vanilla JS
- Hosting: Netlify/Vercel/GitHub Pages
- Database: Supabase (optional)

---

Made with ❤️ for property managers