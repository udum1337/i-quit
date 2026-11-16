/* ============================================================
   Progress screen: stats, heatmap, savings chart, achievements
   ============================================================ */

function heatmapHtml() {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const todayTs = today.getTime();
  const weeks = 12;
  const start = new Date(today);
  const dow = (start.getDay() + 6) % 7;
  start.setDate(start.getDate() - dow - (weeks - 1) * 7);

  const quit = new Date(state.quitDate);
  quit.setHours(0, 0, 0, 0);
  const quitTs = quit.getTime();

  let columns = "";
  for (let w = 0; w < weeks; w++) {
    columns += '<div class="heat-week">';
    for (let d = 0; d < 7; d++) {
      const date = new Date(start);
      date.setDate(start.getDate() + w * 7 + d);
      const ts = date.getTime();
      if (ts > todayTs) {
        columns += '<span class="heat-cell" style="visibility:hidden"></span>';
        continue;
      }
      const clean = ts >= quitTs;
      columns += '<span class="heat-cell' + (clean ? " is-clean" : "") + (ts === todayTs ? " is-today" : "") + '"></span>';
    }
    columns += "</div>";
  }

  return '<div class="card heatmap-card">' +
    '<div class="heatmap-head">' +
      '<div class="heatmap-title">' + t("cleanDaysTitle") + "</div>" +
      '<div class="heatmap-sub">' + t("cleanDaysSub") + "</div>" +
    "</div>" +
    '<div class="heatmap-wrap">' +
      '<div class="heat-labels"><span>' + t("wdMon") + '</span><span></span><span>' + t("wdWed") + '</span><span></span><span>' + t("wdFri") + '</span><span></span><span>' + t("wdSun") + '</span></div>' +
      '<div class="heat-weeks">' + columns + "</div>" +
    "</div>" +
    '<div class="heat-legend">' +
      "<span><i></i>" + t("legendBefore") + "</span>" +
      "<span><i></i>" + t("legendClean") + "</span>" +
    "</div>" +
    "</div>";
}

function savingsChartHtml() {
  const totalDays = getTotalDays();
  const cost = getCostPerDay();
  const maxValue = Math.max(1, cost * Math.max(1, totalDays));
  const points = [];
  const steps = Math.max(1, Math.min(60, totalDays));
  for (let i = 0; i <= steps; i++) {
    const day = totalDays === 0 ? 0 : (i / steps) * totalDays;
    const value = cost * day;
    const x = 4 + (i / steps) * 312;
    const y = 96 - (value / maxValue) * 84;
    points.push({ x: x, y: y });
  }
  const line = points.map(function (p, i) { return (i === 0 ? "M" : "L") + p.x.toFixed(1) + " " + p.y.toFixed(1); }).join(" ");
  const area = "M" + points[0].x.toFixed(1) + " 96 " + points.map(function (p) { return "L" + p.x.toFixed(1) + " " + p.y.toFixed(1); }).join(" ") + " L" + points[points.length - 1].x.toFixed(1) + " 96 Z";
  const last = points[points.length - 1];

  return '<div class="card chart-card">' +
    '<div class="chart-head">' +
      "<div>" +
        '<div class="chart-title">' + t("savingsTitle") + "</div>" +
        '<div class="chart-value" data-live="saved-big">' + fmtMoney(getSavedTotal()) + "</div>" +
        '<div class="chart-sub" data-live="chart-sub">' + t("forDays") + " " + fmtDays(totalDays) + "</div>" +
      "</div>" +
      '<div class="stat-icon" style="margin:0">' + icon("coin", 16) + "</div>" +
    "</div>" +
    '<svg class="chart-svg" viewBox="0 0 320 104" preserveAspectRatio="none" aria-hidden="true">' +
      "<defs><linearGradient id=\"savingsFill\" x1=\"0\" y1=\"0\" x2=\"0\" y2=\"1\">" +
        '<stop offset="0%" stop-color="var(--accent)" stop-opacity=".32"/>' +
        '<stop offset="100%" stop-color="var(--accent)" stop-opacity="0"/>' +
      "</linearGradient></defs>" +
      '<line x1="0" y1="52" x2="320" y2="52" class="grid"/>' +
      '<path class="area" d="' + area + '"/>' +
      '<path class="line" d="' + line + '"/>' +
      '<circle class="dot" cx="' + last.x.toFixed(1) + '" cy="' + last.y.toFixed(1) + '" r="3.2"/>' +
    "</svg>" +
    "</div>";
}

function achievementTile(a, unlocked) {
  return '<button type="button" class="ach-tile' + (unlocked ? "" : " is-locked") + '" data-action="achievement" data-id="' + a.id + '">' +
    '<span class="ach-icon">' + icon(a.icon, 18) + "</span>" +
    '<span class="ach-name">' + a.title[state.lang] + "</span>" +
    "</button>";
}

function renderProgress() {
  const el = document.getElementById("screen-progress");
  if (!el) return;

  const m = getMilestoneState();
  const totalDays = getTotalDays();
  const overall = MILESTONES.length ? (m.unlocked.length / MILESTONES.length) * 100 : 0;
  const unlockedSet = new Set(state.unlocked);

  el.innerHTML =
    '<div class="screen-head">' +
      '<div class="eyebrow">' + t("progressWord") + "</div>" +
      "<h1>" + t("progressTitle") + "</h1>" +
      "<p>" + t("progressSub") + "</p>" +
    "</div>" +

    '<div class="progress-hero">' +
      '<div class="progress-hero-main">' +
        "<div>" +
          '<div class="big" data-live="streak-days">' + getCurrentDays() + "</div>" +
          '<div class="lbl" data-live="streak-days-label">' + pluralDays(getCurrentDays()) + "</div>" +
        "</div>" +
        '<div class="sub">' + t("currentStreak") + " · " + t("slips") + ": " + state.slips + "</div>" +
      "</div>" +
      '<div class="mini-stat"><div class="v" data-live="best-days">' + getBestDays() + "</div><div class=\"l\">" + t("bestStreakShort") + "</div></div>" +
      '<div class="mini-stat"><div class="v" data-live="total-days">' + totalDays + "</div><div class=\"l\">" + t("totalCleanShort") + "</div></div>" +
    "</div>" +

    heatmapHtml() +
    savingsChartHtml() +

    '<div class="section-head"><h2>' + t("achievementsTitle") + "</h2>" +
      '<span class="heatmap-sub" data-live="ach-count">' + getUnlockedAchievements().length + " " + t("of") + " " + ACHIEVEMENTS.length + "</span>" +
    "</div>" +
    '<div class="ach-grid">' + ACHIEVEMENTS.map(function (a) {
      return achievementTile(a, unlockedSet.has(a.id));
    }).join("") + "</div>" +

    '<div class="card" style="margin-top:14px">' +
      '<div class="heatmap-head">' +
        '<div class="heatmap-title">' + t("milestonesTitle") + "</div>" +
        '<div class="heatmap-sub" data-live="milestone-count">' + m.unlocked.length + " " + t("of") + " " + MILESTONES.length + "</div>" +
      "</div>" +
      '<div class="progress-track" style="margin-top:10px"><div class="progress-fill" style="width:' + overall.toFixed(2) + '%"></div></div>' +
      '<button type="button" class="source-chip" style="margin-top:11px" data-action="tab" data-tab="timeline">' + icon("timeline", 12) + " " + t("navTimeline") + "</button>" +
    "</div>" +

    '<div class="settings-footer" style="padding-top:16px">' + t("settingsFooter") + "</div>";
}
