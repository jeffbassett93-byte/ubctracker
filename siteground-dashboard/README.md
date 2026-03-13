# Repair Tracker Dashboard — SiteGround Deployment

## Files to Upload

Upload the entire `siteground-dashboard` folder contents to your SiteGround `public_html` directory (or a subdirectory like `public_html/dashboard`):

```
public_html/
├── index.html          ← Main dashboard page
├── .htaccess           ← Apache rewrite rules
├── api/
│   └── upload.php      ← Receives data from iOS app
└── data/
    └── projects.json   ← Project data (auto-created by PHP)
```

## How to Deploy

1. Log in to **SiteGround → Site Tools → File Manager**
2. Navigate to `public_html` (or create a subdirectory)
3. Upload all files from this folder, preserving the directory structure
4. Make sure the `data/` directory is writable (chmod 755)

## iOS App Setup

In the iOS app's **Dashboard** tab:
1. Enter your SiteGround URL (e.g., `https://yourdomain.com` or `https://yourdomain.com/dashboard`)
2. Tap **Sync to Dashboard**
3. The app will POST project data to `your-url/api/upload.php`

## How It Works

- **iOS app** sends all project data as JSON via POST to `/api/upload.php`
- **PHP endpoint** saves the JSON to `data/projects.json`
- **Dashboard** (`index.html`) loads and displays the data
- No database needed — everything is file-based
- No build step — pure HTML/CSS/JS

## Permissions

If uploads fail, ensure the `data/` directory has write permissions:
```bash
chmod 755 data/
```
