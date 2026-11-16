/* ============================================================
   Bottom sheets: milestone, achievement, sources, disclaimer, slip, reset
   ============================================================ */

function sourceLinks(ids) {
  return '<div class="sources-list">' + ids.map(function (id) {
    const s = SOURCES[id];
    if (!s) return "";
    return '<a class="source-item" href="' + s.url + '" target="_blank" rel="noopener noreferrer">' +
      '<div class="s-org">' + s.org + "</div>" +
      '<div class="s-title">' + s.title[state.lang] + "</div>" +
      '<div class="s-url">' + s.url + "</div>" +
      "</a>";
  }).join("") + "</div>";
}

function renderMilestoneSheet(id) {
  const m = MILESTONE_MAP[id];
  if (!m) return "";
  const unlocked = getElapsedSec() >= m.at;
  const remaining = m.at - getElapsedSec();
  return '<div class="sheet-grabber"></div>' +
    '<button type="button" class="sheet-close" data-action="close-sheet" aria-label="' + t("close") + '">' + icon("close", 14) + "</button>" +
    '<div class="sheet-icon">' + icon(m.icon, 28) + "</div>" +
    '<div class="detail-pill ' + (unlocked ? "is-accent" : "") + '">' + (unlocked ? t("milestoneEarned") : t("milestoneLocked")) + "</div>" +
    "<h2>" + m.title[state.lang] + "</h2>" +
    '<div class="detail-meta"><span class="detail-pill">' + m.time[state.lang] + "</span>" +
      (unlocked ? '<span class="detail-pill is-accent">' + t("unlockedAt") + "</span>" : '<span class="detail-pill">' + t("locked") + "</span>") +
    "</div>" +
    "<p>" + m.desc[state.lang] + "</p>" +
    '<div class="detail-quote">' + m.long[state.lang] + "</div>" +
    (!unlocked ? '<p class="sheet-note">' + t("unlockIn") + " " + fmtDurationShort(remaining) + "</p>" : "") +
    '<div class="detail-section"><div class="detail-section-title">' + t("sourcesLabel") + "</div>" + sourceLinks(m.sources) + "</div>";
}

function renderAchievementSheet(id) {
  const a = ACHIEVEMENT_MAP[id];
  if (!a) return "";
  const unlocked = state.unlocked.indexOf(a.id) !== -1 || isAchievementUnlocked(a);
  return '<div class="sheet-grabber"></div>' +
    '<button type="button" class="sheet-close" data-action="close-sheet" aria-label="' + t("close") + '">' + icon("close", 14) + "</button>" +
    '<div class="sheet-icon">' + icon(a.icon, 28) + "</div>" +
    '<div class="detail-pill ' + (unlocked ? "is-accent" : "") + '">' + (unlocked ? t("achievementEarned") : t("achievementLocked")) + "</div>" +
    "<h2>" + a.title[state.lang] + "</h2>" +
    "<p>" + achievementDesc(a) + "</p>" +
    '<div class="sheet-actions"><button type="button" class="btn-secondary" data-action="close-sheet">' + t("close") + "</button></div>";
}

function renderSourcesSheet() {
  return '<div class="sheet-grabber"></div>' +
    '<button type="button" class="sheet-close" data-action="close-sheet" aria-label="' + t("close") + '">' + icon("close", 14) + "</button>" +
    "<h2>" + t("sourcesTitle") + "</h2>" +
    "<p>" + t("sourcesSub") + "</p>" +
    '<div class="sources-list">' + Object.keys(SOURCES).map(function (id) {
      const s = SOURCES[id];
      return '<a class="source-item" href="' + s.url + '" target="_blank" rel="noopener noreferrer">' +
        '<div class="s-org">' + s.org + "</div>" +
        '<div class="s-title">' + s.title[state.lang] + "</div>" +
        '<div class="s-url">' + s.url + "</div>" +
        "</a>";
    }).join("") + "</div>" +
    '<p class="sheet-note">' + t("settingsFooter") + "</p>";
}

function renderDisclaimerSheet() {
  return '<div class="sheet-grabber"></div>' +
    '<button type="button" class="sheet-close" data-action="close-sheet" aria-label="' + t("close") + '">' + icon("close", 14) + "</button>" +
    "<h2>" + t("disclaimerTitle") + "</h2>" +
    "<p>" + t("disclaimerText") + "</p>" +
    '<div class="sheet-actions"><button type="button" class="btn-secondary" data-action="close-sheet">' + t("close") + "</button></div>";
}

function renderSlipSheet() {
  return '<div class="sheet-grabber"></div>' +
    '<button type="button" class="sheet-close" data-action="close-sheet" aria-label="' + t("close") + '">' + icon("close", 14) + "</button>" +
    '<div class="sheet-icon" style="background:rgba(255,59,48,.12);color:var(--danger)">' + icon("refresh", 28) + "</div>" +
    "<h2>" + t("slipTitle") + "</h2>" +
    "<p>" + t("slipText") + "</p>" +
    '<div class="sheet-actions">' +
      '<button type="button" class="btn-danger" data-action="confirm-slip">' + t("slipConfirm") + "</button>" +
      '<button type="button" class="btn-secondary" data-action="close-sheet">' + t("slipCancel") + "</button>" +
    "</div>";
}

function renderResetSheet() {
  return '<div class="sheet-grabber"></div>' +
    '<button type="button" class="sheet-close" data-action="close-sheet" aria-label="' + t("close") + '">' + icon("close", 14) + "</button>" +
    '<div class="sheet-icon" style="background:rgba(255,59,48,.12);color:var(--danger)">' + icon("trash", 28) + "</div>" +
    "<h2>" + t("resetTitle") + "</h2>" +
    "<p>" + t("resetText") + "</p>" +
    '<div class="sheet-actions">' +
      '<button type="button" class="btn-danger" data-action="confirm-reset">' + t("resetConfirm") + "</button>" +
      '<button type="button" class="btn-secondary" data-action="close-sheet">' + t("resetCancel") + "</button>" +
    "</div>";
}

function renderCurrencySheet() {
  return '<div class="sheet-grabber"></div>' +
    '<button type="button" class="sheet-close" data-action="close-sheet" aria-label="' + t("close") + '">' + icon("close", 14) + "</button>" +
    "<h2>" + t("currency") + "</h2>" +
    "<p>" + t("currencySheetSub") + "</p>" +
    '<div class="currency-list">' + CURRENCY_ORDER.map(function (id) {
      const c = CURRENCIES[id];
      const active = state.currency === id;
      return '<button type="button" class="currency-row' + (active ? " is-active" : "") + '" data-action="set-currency" data-currency="' + id + '" aria-pressed="' + (active ? "true" : "false") + '">' +
        '<span class="currency-badge">' + c.symbol + "</span>" +
        '<span class="currency-main"><span class="currency-code">' + c.code + '</span><span class="currency-name">' + c.label[state.lang] + "</span></span>" +
        (active ? '<span class="currency-check">' + icon("check", 16) + "</span>" : "") +
        "</button>";
    }).join("") + "</div>";
}

function renderSheet() {
  const sheet = document.getElementById("sheet");
  if (!sheet) return;
  if (!ui.sheet) {
    sheet.innerHTML = "";
    sheet.removeAttribute("aria-labelledby");
    return;
  }
  const type = ui.sheet.type;
  let html = "";
  if (type === "milestone") html = renderMilestoneSheet(ui.sheet.payload);
  else if (type === "achievement") html = renderAchievementSheet(ui.sheet.payload);
  else if (type === "sources") html = renderSourcesSheet();
  else if (type === "disclaimer") html = renderDisclaimerSheet();
  else if (type === "slip") html = renderSlipSheet();
  else if (type === "reset") html = renderResetSheet();
  else if (type === "currency") html = renderCurrencySheet();
  sheet.innerHTML = html;
  const title = sheet.querySelector("h2");
  if (title) {
    title.id = "sheet-title";
    sheet.setAttribute("aria-labelledby", "sheet-title");
  }
}
