# GitHub Pages Deployment Guide

This project is configured to automatically deploy to GitHub Pages using GitHub Actions.

## 🚀 Automatic Deployment

Every push to the `main` branch automatically:
1. Exports the Godot game for Web (HTML5)
2. Deploys to GitHub Pages

**Live Game URL:** `https://kagelump.github.io/kkjam/`

## 📋 Setup Instructions

### First-Time Setup

1. **Enable GitHub Pages in Repository Settings**
   - Go to your repository on GitHub
   - Click **Settings** → **Pages**
   - Under "Source", select **GitHub Actions**
   - Save the settings

2. **Push to Main Branch**
   ```bash
   git add .
   git commit -m "Add GitHub Pages deployment"
   git push origin main
   ```

3. **Monitor Deployment**
   - Go to the **Actions** tab in your repository
   - Watch the "Deploy to GitHub Pages" workflow
   - Once complete, visit: `https://kagelump.github.io/kkjam/`

### Manual Deployment

You can also trigger deployment manually:
1. Go to **Actions** tab
2. Select "Deploy to GitHub Pages" workflow
3. Click "Run workflow" → "Run workflow"

## 🛠️ How It Works

### GitHub Actions Workflow

The workflow (`.github/workflows/deploy.yml`) does the following:

1. **Checkout Code** - Downloads your repository
2. **Setup Godot** - Installs Godot 4.3 with export templates
3. **Import Assets** - Ensures all assets are properly imported
4. **Export Game** - Exports to `build/web/index.html` using the "Web" preset
5. **Add COI Service Worker** - Enables SharedArrayBuffer for better performance
6. **Deploy** - Publishes to GitHub Pages

### Export Configuration

The export settings are in `export_presets.cfg`:
- **Platform:** Web (HTML5)
- **Export Path:** `build/web/index.html`
- **Thread Support:** Enabled for better performance
- **VRAM Compression:** Optimized for desktop browsers

## 🎮 Testing Locally

### Export Locally
```bash
# Install Godot export templates first (in Godot Editor: Editor → Manage Export Templates)

# Export for web
godot --headless --export-release "Web" build/web/index.html
```

### Serve Locally
```bash
# Python 3
cd build/web
python -m http.server 8000

# Or using Node.js
npx http-server build/web -p 8000
```

Then open: `http://localhost:8000`

## 🔧 Troubleshooting

### Deployment Fails

1. **Check Actions Tab**
   - Look for error messages in the workflow logs
   - Common issues: missing export templates, syntax errors in scenes

2. **Verify Export Preset**
   - Open project in Godot Editor
   - Go to Project → Export
   - Ensure "Web" preset exists and is configured

3. **Test Local Export**
   - Try exporting locally first to catch errors early

### Game Not Loading

1. **Check Browser Console** (F12)
   - Look for CORS errors, missing files, or JavaScript errors

2. **Clear Cache**
   - Hard refresh: Ctrl+Shift+R (Windows/Linux) or Cmd+Shift+R (Mac)

3. **Check File Paths**
   - Ensure all resources use `res://` paths
   - No absolute file paths

### Cross-Origin Isolation Issues

The workflow includes `coi-serviceworker.min.js` to enable SharedArrayBuffer. If you see warnings about this:
- It's normal for Godot 4.x web exports
- The service worker handles it automatically
- Some features may be slower without it

## 📝 Updating the Game

1. Make your changes locally
2. Test with `make test` and manual play (F5)
3. Commit and push:
   ```bash
   git add .
   git commit -m "Your change description"
   git push origin main
   ```
4. GitHub Actions will automatically deploy the new version
5. Wait 1-2 minutes, then refresh your GitHub Pages URL

## 🔐 Security Notes

- The workflow has minimal permissions (only `contents:read`, `pages:write`, `id-token:write`)
- Export is done in a sandboxed GitHub Actions runner
- No secrets or credentials are required for basic deployment

## 📚 Additional Resources

- [Godot Web Export Documentation](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html)
- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
