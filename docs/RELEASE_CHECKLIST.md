# Stylemake v0.5 - Quick Release Checklist

**Use this checklist on release day**

---

## Pre-Release (1 hour before)

### Environment Verification
- [ ] Supabase project accessible
- [ ] Firebase Console accessible
- [ ] Git repository clean (`git status`)
- [ ] All changes committed to `main` branch
- [ ] Latest code pulled (`git pull`)

### Team Preparation
- [ ] Monitoring team assigned
- [ ] Support email monitored
- [ ] GitHub notifications enabled
- [ ] Escalation contacts confirmed
- [ ] Monitoring schedule printed/shared

### Documentation Review
- [ ] README.md updated ✅
- [ ] Release notes finalized ✅
- [ ] User guide complete ✅
- [ ] Known limitations documented ✅

---

## Release Execution (30-60 minutes)

### Step 1: Build Production Releases

```bash
# Clean previous builds
flutter clean
flutter pub get

# Build Web
flutter build web --release
# Output: build/web/

# Build Android APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Build Android App Bundle (for Play Store)
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab

# Build iOS (macOS only)
flutter build ios --release
# Follow Xcode signing and archive steps
```

### Step 2: Test Production Builds

**Web:**
```bash
# Serve production web build locally
cd build/web
python -m http.server 8000
# Open http://localhost:8000
# Test one complete workflow
```

**Android:**
- Install APK on test device
- Test complete workflow (Style → Cutting → PO → Receipt)
- Verify real-time sync with web

**iOS:**
- Install on test device via Xcode or TestFlight
- Test complete workflow
- Verify real-time sync

### Step 3: Create Git Tag

```bash
# Create annotated tag
git tag -a v0.5.0 -m "Release v0.5.0 - Production Module MVP"

# Push tag to remote
git push origin v0.5.0

# Verify tag created
git tag -l
```

### Step 4: Publish GitHub Release

1. Go to: https://github.com/yourusername/stylemake/releases/new
2. **Tag:** v0.5.0
3. **Title:** Stylemake v0.5.0 - Production Module MVP
4. **Description:** Copy from `RELEASE_NOTES_v0.5.md`
5. **Attach files:**
   - `app-release.apk` (Android)
   - `app-release.aab` (Android App Bundle)
6. Click **"Publish release"**

### Step 5: Deploy Web Version

**Option A: Manual Deploy (Static Host)**
```bash
# Upload build/web/ to your hosting (Netlify, Vercel, etc.)
# Or deploy to Firebase Hosting:
firebase deploy
```

**Option B: GitHub Pages**
```bash
# Push build/web/ to gh-pages branch
# Or use GitHub Actions for automatic deployment
```

### Step 6: Verify Deployment

**Immediately after deploy:**
- [ ] Open production URL in browser
- [ ] Verify app loads without errors
- [ ] Check browser console (no critical errors)
- [ ] Test database connection (should show seed data)
- [ ] Run verification script:
  ```bash
  dart scripts/verify_backup.dart
  ```

**Complete one workflow:**
- [ ] Create a test style
- [ ] Create a test cutting
- [ ] Create a test PO
- [ ] Verify data links correctly

**Check monitoring:**
- [ ] Open Firebase Crashlytics dashboard
- [ ] Verify events being received
- [ ] Open Supabase dashboard
- [ ] Check API logs for requests

---

## Post-Release (Immediate - Hour 0)

### Hour 0 Actions (Within 15 minutes)

- [ ] **Announce release** (email, Slack, etc.)
- [ ] **Start monitoring timer** (48-hour countdown begins)
- [ ] **Set calendar reminders** for monitoring checks
- [ ] **Test real-time sync** (open two tabs, verify updates)
- [ ] **Check Crashlytics** (should show 0 crashes)
- [ ] **Check Supabase metrics** (response times normal)

### Hour 0 Report Template

**Time:** [HH:MM]  
**Status:** Deployed ✅

**Metrics:**
- Web URL: [URL]
- Deployment time: [X minutes]
- Initial tests: ✅ Pass
- Crashlytics: ✅ Active
- Supabase: ✅ Connected

**Issues:** None

---

## Monitoring Schedule (48 Hours)

### Hour 0-4 (Critical Period)
**Every 30 minutes:**
- [ ] Check Firebase Crashlytics
- [ ] Check Supabase logs
- [ ] Review error rates

**Every 1 hour:**
- [ ] Test app functionality (quick workflow)
- [ ] Check user feedback channels

### Hour 4-12 (Active Monitoring)
**Every 2 hours:**
- [ ] Check Crashlytics dashboard
- [ ] Review Supabase metrics

**Every 4 hours:**
- [ ] Test key workflows
- [ ] Check email support inbox

### Hour 12-24 (Standard Monitoring)
**Every 4 hours:**
- [ ] Check error dashboards

**Every 6 hours:**
- [ ] Review metrics
- [ ] Check support channels

### Hour 24-48 (Reduced Monitoring)
**Every 6 hours:**
- [ ] Check Crashlytics
- [ ] Review Supabase metrics
- [ ] Check support channels

**Once per day:**
- [ ] Full functionality test

---

## Quick Issue Response

### If Crash Rate > 2%
1. ⚠️ **URGENT** - Check Crashlytics immediately
2. Identify crash cause
3. Assess impact (all users or subset?)
4. Notify team
5. Begin hotfix or consider rollback

### If Database Errors
1. Check Supabase status page
2. Review recent queries in Supabase logs
3. Verify connection strings
4. Check rate limits
5. Contact Supabase support if needed

### If Real-time Sync Fails
1. Check Supabase Realtime status
2. Verify Realtime enabled in Supabase dashboard
3. Test with fresh browser session
4. Check browser console for errors
5. Review WebSocket connections

---

## Rollback Procedure (If Needed)

### Trigger Conditions
- Crash-free users < 98%
- Data loss reported
- Critical functionality completely broken
- Multiple unresolved P0 issues

### Rollback Steps (30 minutes)

```bash
# 1. Revert to previous stable version
git checkout v0.4.0  # or last known good version

# 2. Rebuild
flutter clean
flutter pub get
flutter build web --release

# 3. Redeploy
# Upload build/web/ to hosting
# Or: firebase deploy

# 4. Notify users
# Send email/announcement about rollback

# 5. Verify
# Test that previous version works
# Monitor for stability
```

---

## Hotfix Procedure (If Needed)

### When to Hotfix
- Single critical bug with known fix
- Crash affecting < 5% of users
- Issue can be fixed in < 2 hours

### Hotfix Steps (3-4 hours)

```bash
# 1. Create hotfix branch
git checkout -b hotfix/v0.5.1

# 2. Make minimal fix
# Edit only necessary files

# 3. Test fix thoroughly
flutter test
flutter run  # Manual testing

# 4. Commit and tag
git commit -m "Hotfix: [describe fix]"
git tag -a v0.5.1 -m "Hotfix v0.5.1 - [describe fix]"

# 5. Build and deploy
flutter build web --release
# Deploy to production

# 6. Merge to main
git checkout main
git merge hotfix/v0.5.1
git push origin main
git push origin v0.5.1

# 7. Verify and monitor
```

---

## 48-Hour Completion

### After 48 Hours

- [ ] **Generate final report** (use template in post_release_monitoring.md)
- [ ] **Document all issues** found and resolved
- [ ] **Update Known Issues** list in README
- [ ] **Send summary email** to stakeholders
- [ ] **Transition to standard support** (reduce monitoring frequency)
- [ ] **Celebrate! 🎉** Release successful!

### Success Criteria

✅ Release successful if:
- Crash-free users > 99.5%
- No critical issues
- < 5 high-priority issues
- All reported critical issues resolved
- Performance meets targets

### Final Actions

- [ ] Archive monitoring logs
- [ ] Update issue tracker
- [ ] Plan next sprint (v0.6)
- [ ] Post-mortem if needed
- [ ] Team retrospective

---

## Emergency Contacts

**Technical Lead:** [Name / Contact]  
**Project Manager:** [Name / Contact]  
**Supabase Support:** https://supabase.com/support  
**Firebase Support:** https://firebase.google.com/support

---

## Quick Reference Commands

```bash
# Verify database
dart scripts/verify_backup.dart

# Check Flutter version
flutter --version

# Clean and rebuild
flutter clean && flutter pub get && flutter run

# View app logs (mobile)
flutter logs

# Check for analysis errors
dart analyze

# Run tests
flutter test
```

---

## Important URLs

- **GitHub Repo:** [URL]
- **Production Web:** [URL]
- **Firebase Console:** https://console.firebase.google.com/project/YOUR_PROJECT
- **Supabase Dashboard:** https://app.supabase.com/project/YOUR_PROJECT
- **Release Notes:** [GitHub Release URL]

---

## Notes

- Keep this checklist open during release
- Check off items as you complete them
- Take notes on any issues encountered
- Time-stamp all major actions
- Communicate status regularly

---

**Good luck with the release! 🚀**

*For detailed information, see:*
- `docs/v0.5_release_readiness.md` - Full readiness report
- `docs/post_release_monitoring.md` - Detailed monitoring guide
- `RELEASE_NOTES_v0.5.md` - Complete release notes

