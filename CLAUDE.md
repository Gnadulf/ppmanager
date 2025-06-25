# CLAUDE.md - Property Manager Project Guidelines

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 🧠 ULTRATHINK: Always Activated

- Think deeply and critically about every problem
- No shortcuts, no placeholders
- Proactively identify and solve deployment/security issues
- Consider edge cases in property management workflows
- Every fix must be tracked in `roadmap.md`

## 🎯 Work Philosophy

- **Production-ready from day 1** - No prototypes, only production code
- **Privacy by design** - Sensitive property data (tenant info, budgets, contracts)
- **Offline-first with seamless sync** - Field workers depend on reliability
- **Property owner/manager experience over developer convenience** - Real users, real problems

## 💡 Context Awareness

- **PP-Manager**: Property & Project Management PWA
- **Multi-device sync**: Via Supabase (already configured)
- **Offline capability is critical**: Field work without internet
- **Build upon existing architecture**: Single-file app, no dependencies
- **Current state**: Pre-deployment, needs critical fixes (see roadmap.md Phase 1)

## 🏡 Project-Specific Patterns

### Property Manager Architecture
- **Offline-First**: LocalStorage → Supabase sync when online
- **Mobile-First**: Field workers use phones/tablets primarily  
- **Data Integrity**: Never lose a task or project
- **Progressive Enhancement**: Works without internet, better with it
- **Single-File Design**: Everything in index.html for maximum reliability

### File Structure
```
PP-Manager/
├── index.html                    # Main application (or property-manager-complete.html)
├── service-worker.js             # PWA offline functionality
├── manifest-json.json            # ⚠️ Needs rename to manifest.json
├── icon-generator.html           # Tool to generate required icons
├── supabase-integration-2.js    # Cloud sync implementation
├── supabase-schema.sql          # Database schema
└── roadmap.md                   # Development phases & tracking
```

## 🚀 Always Consider

- **What happens when offline for days?** LocalStorage persists, sync queues changes
- **How to handle sync conflicts?** Last-write-wins with timestamps
- **Property data privacy?** Tenant info, budgets stay local until explicit sync
- **Accessibility for older property managers?** Large touch targets, high contrast
- **Multi-language support?** German/English ready, i18n structure for future

## ⚡ Concrete Expectations

- **Complete deployment solutions** - Vercel with PWA ready
- **Explain security implications** - Every API key, every data flow
- **Warn about data loss scenarios** - LocalStorage limits, sync failures
- **Test on real devices** - iOS Safari, Android Chrome minimum
- **Consider backup strategies** - Export/Import already implemented
- **Track progress** - All changes documented in roadmap.md

## 🔧 Technology Stack

- **Vanilla JS** - No framework dependencies, maximum compatibility
- **LocalStorage** - Primary data store, 5-10MB limit
- **Supabase** - Optional sync, Row Level Security enabled
- **Service Worker** - Offline caching, background sync prep
- **Vercel** - Static hosting with environment variables

### Core Data Models
```javascript
// Task Model
{
  id: timestamp,
  title: string,
  building: string,
  priority: "hoch|mittel|niedrig",
  deadline: "YYYY-MM-DD",
  recurrence: "daily|weekly|8weeks|16weeks|yearly",
  contractor: contractorId,
  budget: number,
  completed: boolean,
  status: "todo|progress|done"
}

// State Management
this.state = {
  tasks: [],
  projects: [],
  contractors: [],
  documents: [],
  currentView: 'tasks',
  currentBuilding: 'all'
};
```

## 📱 Development Workflow

1. **Test offline scenarios first** - Disable network, ensure functionality
2. **Mobile testing before desktop** - Touch targets, viewport, performance
3. **Real device testing** - Not just emulators (iOS Safari quirks!)
4. **Security audit before deployment** - Check escapeHtml, CSP headers
5. **Performance on slow devices** - 2015+ smartphones, 3G networks
6. **Update roadmap.md** - Track every fix and enhancement

### Local Development
```bash
# Recommended: Local server for Service Worker
python -m http.server 8000
# Open: http://localhost:8000

# Quick test (limited functionality)
open index.html
```

## 🎨 UI/UX Principles

- **Large touch targets** - Minimum 44x44px (field use with gloves)
- **High contrast** - WCAG AA minimum (outdoor visibility)
- **Minimal data entry** - Dropdowns over text fields
- **Quick actions** - One-handed operation priority
- **Clear visual feedback** - Loading states, success confirmations
- **UI Language** - German or English (configurable)
- **Code Language** - English for all variables, functions, comments

## 🛡️ Security & Privacy

### Immediate Fixes Required (Phase 1)
```javascript
// CRITICAL: Add to PropertyManager class
escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}
```

### Security Checklist
- [ ] Encrypt sensitive data (see roadmap.md Phase 2)
- [ ] No data leaks to console (remove all console.log)
- [ ] Secure API keys handling (environment variables only)
- [ ] GDPR compliance (data export exists, need deletion)
- [ ] Regular security audits (quarterly minimum)

## 🔄 Problem-Solving Approach

When implementing features:
1. **Consider offline scenario first** - It's the default state
2. **Design for mobile constraints** - Small screen, fat fingers, glare
3. **Implement with sync in mind** - Queue changes, handle conflicts
4. **Test data integrity** - Export, clear, import cycle
5. **Plan rollback strategy** - Every change reversible
6. **Document in roadmap.md** - Track progress systematically

## 📊 Property Management Context

- **Tasks**: Daily maintenance, scheduled inspections, emergency repairs
- **Projects**: Major renovations, compliance upgrades, modernization
- **Contractors**: Plumbers, electricians, cleaners, inspectors
- **Budget**: Track per building, alert on overruns
- **Compliance**: Verkehrssicherungspflichten (safety obligations)
  - Fire safety, water quality, structural integrity
  - Automated deadline tracking with recurrence

## ⚠️ Critical Requirements

1. **Never lose user data** - LocalStorage + backup exports
2. **Work offline indefinitely** - Full functionality without internet
3. **Sync without conflicts** - Queue system with retry logic
4. **Secure sensitive information** - Tenant data, financial records
5. **Fast on old devices** - < 3s load on 2015 smartphones

## 🚧 Current Issues to Fix

### Phase 1 - MVP Deployment (roadmap.md)
1. **PWA deployment readiness**
   ```html
   <!-- Add to <head> -->
   <link rel="manifest" href="/manifest.json">
   <meta name="theme-color" content="#007aff">
   <link rel="apple-touch-icon" href="/icon-192.png">
   
   <!-- Add before </body> -->
   <script>
   if ('serviceWorker' in navigator) {
       navigator.serviceWorker.register('/service-worker.js');
   }
   </script>
   ```

2. **Icon generation completion**
   - Use icon-generator.html
   - Create: icon-96.png, icon-192.png, icon-512.png

3. **Security vulnerabilities (XSS)**
   - Add escapeHtml function
   - Sanitize all user inputs

4. **Proper file naming**
   ```bash
   mv manifest-json.json manifest.json
   mv vercel-json.json vercel.json
   mv package-json.json package.json
   mv gitignore.txt .gitignore
   ```

5. **Supabase integration**
   - Environment variables in Vercel
   - Test sync functionality

## Meta-Rules

- **Property data is sensitive** - Privacy first, features second
- **Field workers have different needs** - Offline, quick, reliable
- **Offline is the default state** - Online is a bonus
- **Sync is a luxury, not a requirement** - Must work without it
- **Simple > Complex for field use** - Less taps, less confusion
- **Track everything in roadmap.md** - Systematic progress

---

**"Build for the property manager in the field with spotty internet, not the developer with fiber optic."**

## 🎯 Success Metrics

- [ ] Installs successfully as PWA on iOS/Android
- [ ] Works offline for weeks without data loss
- [ ] Syncs without conflicts when online
- [ ] Loads in < 3 seconds on 3G
- [ ] Zero security vulnerabilities in audit
- [ ] All Phase 1 items in roadmap.md completed

## 📚 References

- **Roadmap**: See `roadmap.md` for development phases
- **Issues**: Track all bugs and features in roadmap.md
- **Testing**: Document test results in roadmap.md
- **Deployment**: Update roadmap.md after each release