/* ============================================================
   Onboarding flow (5 steps)
   ============================================================ */

function obDots() {
  let html = '<div class="ob-dots">';
  for (let i = 1; i <= 5; i++) {
    html += '<span class="ob-dot' + (i === onboarding.step ? " is-active" : "") + '"></span>';
  }
  return html + "</div>";
}

function obFeature(iconName, text) {
  return '<div class="ob-feature">' +
    '<span class="ob-feature-icon">' + icon(iconName, 16) + "</span>" +
    '<span class="ob-feature-text">' + text + "</span>" +
    "</div>";
}

function obQuickActive(days) {
  const target = Date.now() - days * DAY * 1000;
  return Math.abs(onboarding.quitDate - target) < 5 * 60 * 1000;
}

function obQuickChip(days, label) {
  return '<button type="button" class="quick-chip' + (obQuickActive(days) ? " is-active" : "") + '" data-action="ob-quick" data-days="' + days + '">' + label + "</button>";
}

function obCurrencyChip(id) {
  const c = CURRENCIES[id];
  if (!c) return "";
  return '<button type="button" class="currency-chip' + (onboarding.currency === id ? " is-active" : "") + '" data-action="ob-currency" data-currency="' + id + '" aria-pressed="' + (onboarding.currency === id ? "true" : "false") + '">' +
    '<span class="currency-symbol">' + c.symbol + "</span>" +
    '<span class="currency-code">' + c.code + "</span>" +
    "</button>";
}

function renderOnboarding() {
  const el = document.getElementById("onboarding");
  if (!el) return;

  const p = PRODUCTS[onboarding.product] || PRODUCTS.cigarettes;
  const step = onboarding.step;
  const isEdit = onboarding.mode === "edit";
  const showBack = step > 1 && !(isEdit && step === 2);
  let content = "";
  let footerLabel = t("next");
  let footerDisabled = false;

  if (step === 1) {
    content =
      '<div class="ob-illustration">' + icon("noSmoke", 68) + "</div>" +
      '<h2 class="ob-title">' + t("obWelcomeTitle") + "</h2>" +
      '<p class="ob-sub">' + t("obWelcomeSub") + "</p>" +
      '<div class="ob-features">' +
        obFeature("trophy", t("obFeature1")) +
        obFeature("heart", t("obFeature2")) +
        obFeature("coin", t("obFeature3")) +
      "</div>";
    footerLabel = t("obStart");
  }

  if (step === 2) {
    content =
      '<h2 class="ob-h2">' + (isEdit ? t("obEditTitle") : t("obProductTitle")) + "</h2>" +
      '<p class="ob-p">' + t("obProductSub") + "</p>" +
      '<div class="product-grid">' + Object.keys(PRODUCTS).map(function (id, index, arr) {
        const prod = PRODUCTS[id];
        const selected = onboarding.product === id;
        const span = arr.length % 2 === 1 && index === arr.length - 1 ? ' style="grid-column: span 2; flex-direction: row; align-items: center;"' : "";
        return '<button type="button" class="product-option' + (selected ? " is-selected" : "") + '" data-action="ob-product" data-id="' + id + '"' + span + ">" +
          '<span class="product-icon">' + icon(prod.icon, 21) + "</span>" +
          '<span class="product-name">' + prod.name[state.lang] + "</span>" +
          "</button>";
      }).join("") + "</div>";
  }

  if (step === 3) {
    content =
      '<h2 class="ob-h2">' + t("obQuitTitle") + "</h2>" +
      '<p class="ob-p">' + t("obQuitSub") + "</p>" +
      '<div class="field">' +
        '<label for="ob-date">' + t("quitDate") + "</label>" +
        '<input id="ob-date" type="datetime-local" data-ob-field="date" value="' + toLocalInput(onboarding.quitDate) + '" max="' + toLocalInput(Date.now()) + '">' +
      "</div>" +
      '<div class="quick-row">' +
        obQuickChip(0, t("obQuickNow")) +
        obQuickChip(1, t("obQuickYesterday")) +
        obQuickChip(3, t("obQuick3")) +
        obQuickChip(7, t("obQuickWeek")) +
      "</div>" +
      '<p class="ob-note">' + t("obNoteDate") + "</p>";
  }

  if (step === 4) {
    const packField = p.packLabel
      ? '<div class="field"><label for="ob-pack">' + p.packLabel[state.lang] + '</label><input id="ob-pack" type="number" inputmode="decimal" step="any" min="1" data-ob-field="pack" value="' + onboarding.pack + '"></div>'
      : "";
    const priceField = '<div class="field"><label for="ob-price">' + p.priceLabel[state.lang] + '</label><input id="ob-price" type="number" inputmode="decimal" step="any" min="0" data-ob-field="price" value="' + onboarding.price + '"></div>';

    content =
      '<h2 class="ob-h2">' + t("obMoneyTitle") + "</h2>" +
      '<p class="ob-p">' + t("obMoneySub") + "</p>" +
      '<div class="field"><label for="ob-units">' + p.unit[state.lang] + '</label><input id="ob-units" type="number" inputmode="decimal" step="any" min="0" data-ob-field="units" value="' + onboarding.units + '"></div>' +
      '<div class="field" role="group" aria-labelledby="ob-currency-label"><label id="ob-currency-label">' + t("currency") + '</label><div class="currency-grid">' + CURRENCY_ORDER.map(obCurrencyChip).join("") + '</div><p class="field-hint">' + t("currencyHint") + "</p></div>" +
      (p.packLabel
        ? '<div class="field-row">' + priceField + packField + "</div>"
        : priceField) +
      '<div class="calc-line"><span>' + t("obPerDay") + '</span><b data-ob-cost>' + fmtMoney(calculateOnboardingCost(), onboarding.currency) + "</b></div>" +
      '<p class="ob-note">' + t("obNoteMoney") + "</p>";
  }

  if (step === 5) {
    content =
      '<div class="bell-orb">' + icon("bell", 58) + "</div>" +
      '<h2 class="ob-h2" style="text-align:center">' + t("obNotificationsTitle") + "</h2>" +
      '<p class="ob-p" style="text-align:center">' + t("obNotificationsSub") + "</p>" +
      '<div class="settings-card" style="margin-top:20px">' +
        '<button type="button" class="settings-row" data-action="ob-toggle-notifications">' +
          '<span class="row-icon">' + icon("bell", 15) + "</span>" +
          '<span class="row-main"><span class="row-title">' + t("obBell") + "</span></span>" +
          '<span class="switch' + (onboarding.notifications ? " is-on" : "") + '"></span>' +
        "</button>" +
      "</div>" +
      '<p class="ob-note" style="text-align:center">' + t("obNoteNotifications") + "</p>";
    footerLabel = isEdit ? t("obSave") : t("obFinish");
  }

  el.innerHTML =
    '<div class="ob-top">' +
      '<button type="button" class="ob-back' + (showBack ? "" : " is-hidden") + '" data-action="ob-back" aria-label="' + t("back") + '">' + icon("back", 17) + "</button>" +
      obDots() +
      '<button type="button" class="ob-skip" data-action="ob-skip">' + (isEdit ? t("cancel") : t("obSkip")) + "</button>" +
    "</div>" +
    '<div class="ob-scroll">' + content + "</div>" +
    '<div class="ob-footer"><button type="button" class="ob-cta" data-action="ob-next"' + (footerDisabled ? " disabled" : "") + ">" + footerLabel + "</button></div>";

  const heading = el.querySelector("h2");
  if (heading) heading.id = "ob-title";
  el.setAttribute("aria-hidden", "false");
}
