# Quick Deployment Reference

## 🎯 First Time Setup

1. **Enable GitHub Pages**
   - Go to: Repository Settings → Pages
   - Source: **GitHub Actions**
   - Click Save

2. **Push to trigger deployment**
   ```bash
   git push origin main
   ```

3. **Visit your game**
   - URL: `https://kagelump.github.io/kkjam/`
   - Wait 1-2 minutes for first deployment

## 🚀 Daily Workflow

```bash
# Make changes to your game
# Test locally
make test
make run

# Export and test web version (optional)
make export-web
make serve  # Visit http://localhost:8000

# Commit and push
git add .
git commit -m "Your changes"
git push origin main

# GitHub Actions automatically deploys to Pages
# Check progress at: https://github.com/kagelump/kkjam/actions
```

## 📋 Useful Commands

```bash
make help           # Show all available commands
make test           # Run all tests
make run            # Run game in Godot
make export-web     # Export for web
make serve          # Serve web build locally
make clean          # Clean build files
```

## 🔍 Monitoring

- **Actions Tab**: `https://github.com/kagelump/kkjam/actions`
- **Deployment Status**: Green checkmark = success
- **Build Time**: ~2-3 minutes typically

## 🐛 Common Issues

**"Workflow not found"**
→ Make sure `.github/workflows/deploy.yml` exists

**"Export failed"**
→ Check that `export_presets.cfg` has "Web" preset
→ Verify all scene files are valid

**"Page not loading"**
→ Wait 1-2 minutes after deployment
→ Hard refresh browser (Ctrl+Shift+R)

**"SharedArrayBuffer error"**
→ This is handled automatically by coi-serviceworker
→ Some features may be slower but game should work

## 📖 Full Documentation

See `DEPLOYMENT.md` for complete guide.
