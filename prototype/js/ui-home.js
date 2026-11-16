/* ============================================================
   Home screen
   ============================================================ */

function statCard(iconName, value, label, liveKey) {
  return '<div class="stat-card">' +
    '<div class="stat-icon">' + icon(iconName, 16) + "</div>" +
    '<div class="stat-value"' + (liveKey ? ' data-live="' + liveKey + '"' : "") + ">" + value + "</div>" +
    '<div class="stat-label">' + label + "</div>" +
    "</div>";
}

function miniAchievement(a, locked) {
  return '<button type="button" class="ach-card' + (locked ? " is-locked" : "") + '" data-action="achievement" data-id="' + a.id + '">' +
    '<span class="ach-icon">' + icon(a.icon, 19) + "</span>" +
    '<span class="ach-name">' + a.title[state.lang] + "</span>" +
    "</button>";
}

function renderHome() {
  const el = document.getElementById("screen-home");
  if (!el) return;

  const m = getMilestoneState();
  const elapsed = m.elapsed;
  const next = m.next;
  const current = m.prev;
  const bestDays = getBestDays();
  const currentDays = getCurrentDays();
  const totalDays = getTotalDays();
  const circumference = 2 * Math.PI * 84;
  const dash = circumference * (1 - m.progress);
  const allUnlocked = !next;
  const sourceOrgs = current
    ? current.sources.slice(0, 2).map(function (id) { return SOURCES[id].org; }).join(" · ")
    : "WHO · NHS";

  const unlocked = getUnlockedAchievements();
  const locked = getLockedAchievements();
  const preview = unlocked.concat(locked).slice(0, 8);

  const benefitTitle = current ? current.title[state.lang] : t("startBenefitTitle");
  const benefitDesc = current ? current.desc[state.lang] : t("startBenefitDesc");
  const benefitIcon = current ? current.icon : "heart";
  const benefitId = current ? current.id : MILESTONES[0].id;

  el.innerHTML =
    '<div class="screen-head">' +
      '<div class="eyebrow" data-live="today">' + fmtDate(Date.now(), "long") + "</div>" +
      "<h1>" + t("overview") + "</h1>" +
      "<p>" + t("overviewSub") + "</p>" +
    "</div>" +

    '<section class="hero-card">' +
      '<div class="hero-ring">' +
        '<svg viewBox="0 0 192 192" class="ring" aria-hidden="true">' +
          '<circle cx="96" cy="96" r="84" fill="none" stroke-width="12" class="track"/>' +
          '<circle cx="96" cy="96" r="84" fill="none" stroke-width="12" class="value" stroke-dasharray="' + circumference.toFixed(1) + '" stroke-dashoffset="' + dash.toFixed(1) + '" data-live="ring"/>' +
        "</svg>" +
        '<div class="hero-center">' +
          '<div class="hero-days" data-live="days">' + currentDays + "</div>" +
          '<div class="hero-days-label" data-live="days-label">' + pluralDays(currentDays) + "</div>" +
          '<div class="hero-hms" data-live="hms">' + fmtHMS(elapsed) + "</div>" +
        "</div>" +
      "</div>" +
      '<div class="hero-footer">' +
        '<div class="hero-chip">' + icon("trophy", 13) + " " + t("bestStreak") + ": <b><span data-live=\"best-days\">" + bestDays + "</span> <span data-live=\"best-days-label\">" + pluralDays(bestDays) + "</span></b></div>" +
        '<div class="hero-next" data-live="hero-next">' + (next ? fmtCountdown(next.at - elapsed) : t("allMilestonesDone")) + "</div>" +
      "</div>" +
    "</section>" +

    '<section class="card next-card">' +
      '<div class="card-label">' + t("nextMilestone") + "</div>" +
      '<div class="next-row">' +
        '<div class="next-icon">' + icon(allUnlocked ? "check" : next.icon, 22) + "</div>" +
        '<div style="flex:1;min-width:0">' +
          '<div class="next-title" data-live="next-title">' + (next ? next.title[state.lang] : t("allMilestonesDone")) + "</div>" +
          '<div class="next-sub" data-live="next-countdown">' + (next ? fmtCountdown(next.at - elapsed) : t("allDone")) + "</div>" +
        "</div>" +
      "</div>" +
      '<div class="progress-track"><div class="progress-fill" data-live="next-progress" style="width:' + (m.progress * 100).toFixed(2) + '%"></div></div>' +
    "</section>" +

    '<section class="card benefit-card">' +
      '<div class="benefit-head">' +
        '<div class="benefit-icon">' + icon(benefitIcon, 22) + "</div>" +
        "<div>" +
          '<div class="card-label">' + t("nowInBody") + "</div>" +
          '<div class="benefit-title" data-live="current-benefit-title">' + benefitTitle + "</div>" +
        "</div>" +
      "</div>" +
      '<div class="benefit-desc" data-live="current-benefit-desc">' + benefitDesc + "</div>" +
      '<button type="button" class="source-chip" data-action="milestone" data-id="' + benefitId + '">' + icon("info", 12) + " " + t("source") + ": " + sourceOrgs + "</button>" +
    "</section>" +

    '<div class="stats-grid">' +
      statCard("coin", fmtMoney(getSavedTotal()), t("moneySaved"), "saved") +
      statCard("noSmoke", formatAvoided(), t("cigarettesAvoided"), "avoided") +
      statCard("trophy", fmtDays(bestDays), t("bestLabel"), "best-short") +
      statCard("calendar", fmtDays(totalDays), t("totalLabel"), "total-short") +
    "</div>" +

    '<div class="section-head"><h2>' + t("achievements") + "</h2><button type=\"button\" data-action=\"tab\" data-tab=\"progress\">" + t("seeAll") + "</button></div>" +
    '<div class="ach-scroll">' + preview.map(function (a) {
      return miniAchievement(a, state.unlocked.indexOf(a.id) === -1);
    }).join("") + "</div>" +

    '<div style="display:flex;justify-content:center;margin-top:18px">' +
      '<button type="button" class="source-chip" data-action="sources">' + icon("shield", 12) + " " + t("sources") + "</button>" +
    "</div>" +
    '<div class="settings-footer" style="padding-top:14px">' + t("settingsFooter") + "</div>";
}
