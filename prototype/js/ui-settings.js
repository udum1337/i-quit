/* ============================================================
   Settings screen
   ============================================================ */

function settingsRow(opts) {
  const danger = opts.danger ? " is-danger" : "";
  const action = opts.action ? ' data-action="' + opts.action + '"' : "";
  const value = opts.value ? '<span class="row-value">' + opts.value + "</span>" : "";
  const chevron = opts.chevron ? '<span class="chevron">' + icon("chevron", 14) + "</span>" : "";
  const sub = opts.sub ? '<div class="row-sub">' + opts.sub + "</div>" : "";
  return '<button type="button" class="settings-row' + danger + '"' + action + ">" +
    '<span class="row-icon">' + icon(opts.icon, 15) + "</span>" +
    '<span class="row-main"><span class="row-title">' + opts.title + "</span>" + sub + "</span>" +
    value + chevron +
    "</button>";
}

function renderSettings() {
  const el = document.getElementById("screen-settings");
  if (!el) return;

  const p = getProduct();

  el.innerHTML =
    '<div class="screen-head">' +
      '<div class="eyebrow">' + t("settingsSub") + "</div>" +
      "<h1>" + t("settingsTitle") + "</h1>" +
    "</div>" +

    '<div class="settings-profile">' +
      '<div class="profile-avatar">' + icon(p.icon, 26) + "</div>" +
      '<div style="min-width:0">' +
        '<div class="profile-name">' + p.name[state.lang] + "</div>" +
        '<div class="profile-sub" data-live="profile-sub">' + formatProfileSub() + "</div>" +
      "</div>" +
      '<button type="button" class="profile-edit" data-action="edit-plan">' + t("edit") + "</button>" +
    "</div>" +

    '<div class="settings-group">' +
      '<div class="settings-group-title">' + t("planGroup") + "</div>" +
      '<div class="settings-card">' +
        settingsRow({ icon: p.icon, title: t("product"), value: p.name[state.lang], action: "edit-plan", chevron: true }) +
        settingsRow({ icon: "calendar", title: t("quitDate"), value: fmtDate(state.quitDate, "datetime"), action: "edit-plan", chevron: true }) +
        settingsRow({ icon: "activity", title: t("consumption"), value: formatConsumption(), action: "edit-plan", chevron: true }) +
        settingsRow({ icon: "coin", title: t("price"), value: formatPrice(), action: "edit-plan", chevron: true }) +
        settingsRow({ icon: "banknote", title: t("currency"), value: formatCurrencyValue(), action: "open-currency", chevron: true }) +
        settingsRow({ icon: "refresh", title: t("slipRow"), sub: t("slipRowSub"), action: "open-slip", danger: true, chevron: true }) +
      "</div>" +
    "</div>" +

    '<div class="settings-group">' +
      '<div class="settings-group-title">' + t("notifications") + "</div>" +
      '<div class="settings-card">' +
        '<button type="button" class="settings-row" data-action="toggle-notifications">' +
          '<span class="row-icon">' + icon("bell", 15) + "</span>" +
          '<span class="row-main"><span class="row-title">' + t("notifications") + '</span><span class="row-sub">' + t("notificationsSub") + "</span></span>" +
          '<span class="switch' + (state.notifications ? " is-on" : "") + '"></span>' +
        "</button>" +
      "</div>" +
    "</div>" +

    '<div class="settings-group">' +
      '<div class="settings-group-title">' + t("appearance") + "</div>" +
      '<div class="settings-card">' +
        '<div class="settings-row" style="flex-direction:column;align-items:stretch;gap:9px">' +
          '<div style="display:flex;align-items:center;gap:11px">' +
            '<span class="row-icon">' + icon("moon", 15) + "</span>" +
            '<span class="row-main"><span class="row-title">' + t("appearance") + "</span></span>" +
          "</div>" +
          '<div class="segmented">' +
            '<button type="button" data-action="settings-theme" data-theme="system" class="' + (state.theme === "system" ? "is-active" : "") + '">' + t("system") + "</button>" +
            '<button type="button" data-action="settings-theme" data-theme="light" class="' + (state.theme === "light" ? "is-active" : "") + '">' + t("light") + "</button>" +
            '<button type="button" data-action="settings-theme" data-theme="dark" class="' + (state.theme === "dark" ? "is-active" : "") + '">' + t("dark") + "</button>" +
          "</div>" +
        "</div>" +
        '<div class="settings-row" style="flex-direction:column;align-items:stretch;gap:9px">' +
          '<div style="display:flex;align-items:center;gap:11px">' +
            '<span class="row-icon">' + icon("globe", 15) + "</span>" +
            '<span class="row-main"><span class="row-title">' + t("language") + "</span></span>" +
          "</div>" +
          '<div class="segmented">' +
            '<button type="button" data-action="settings-lang" data-lang="ru" class="' + (state.lang === "ru" ? "is-active" : "") + '">' + t("russian") + "</button>" +
            '<button type="button" data-action="settings-lang" data-lang="en" class="' + (state.lang === "en" ? "is-active" : "") + '">' + t("english") + "</button>" +
          "</div>" +
        "</div>" +
      "</div>" +
    "</div>" +

    '<div class="settings-group">' +
      '<div class="settings-group-title">' + t("dataGroup") + "</div>" +
      '<div class="settings-card">' +
        settingsRow({ icon: "download", title: t("exportData"), sub: t("exportDataSub"), action: "export", chevron: true }) +
        settingsRow({ icon: "trash", title: t("resetData"), sub: t("resetDataSub"), action: "open-reset", danger: true, chevron: true }) +
      "</div>" +
    "</div>" +

    '<div class="settings-group">' +
      '<div class="settings-group-title">' + t("aboutGroup") + "</div>" +
      '<div class="settings-card">' +
        settingsRow({ icon: "shield", title: t("sourcesRow"), sub: t("sourcesRowSub"), action: "sources", chevron: true }) +
        settingsRow({ icon: "info", title: t("disclaimerRow"), sub: t("disclaimerRowSub"), action: "disclaimer", chevron: true }) +
        '<div class="settings-row">' +
          '<span class="row-icon">' + icon("sparkles", 15) + "</span>" +
          '<span class="row-main"><span class="row-title">' + t("version") + '</span><span class="row-sub">' + t("appName") + " · prototype</span></span>" +
          '<span class="row-value">1.0.0</span>' +
        "</div>" +
      "</div>" +
    "</div>" +

    '<div class="settings-footer">' +
      '<div class="settings-brand">' + t("appName") + "</div>" +
      "<div>" + t("madeWith") + "</div>" +
      '<div style="margin-top:6px">' + t("settingsFooter") + "</div>" +
    "</div>";
}
