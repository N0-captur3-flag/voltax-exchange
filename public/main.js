"use strict";
(() => {
  const locale = "ru";
  const messages = {
    "app.mountMissing": "Точка монтирования приложения не найдена",
    "app.title": "VoltaX Exchange",
    "skip.workspace": "Перейти к рабочей области",
    "aria.primary": "Основная навигация",
    "aria.advancedSummary": "Сводка рабочего процесса",
    "aria.marketSummary": "Сводка выбранного рынка",
    "aria.accountSummary": "Сводка аккаунта",
    "aria.workflowStatus": "Статус рабочего процесса",
    "nav.trade": "Торги",
    "nav.portfolio": "Портфель",
    "nav.rfq": "RFQ",
    "nav.partner": "Партнёр",
    "nav.automation": "Условные",
    "nav.feed": "Лента",
    "action.signIn": "Войти",
    "action.signOut": "Выйти",
    "action.close": "Закрыть",
    "action.cancel": "Отмена",
    "action.continue": "Продолжить",
    "action.retry": "Повторить",
    "action.refresh": "Обновить",
    "action.edit": "Изменить",
    "action.submitOrder": "Отправить заявку",
    "action.submitting": "Отправка...",
    "action.cancelOrder": "Отменить заявку",
    "action.cancelling": "Отмена...",
    "action.keepOrder": "Оставить заявку",
    "action.accept": "Принять",
    "action.ownerDetail": "Детали инициатора",
    "action.workup": "Рабочий просмотр",
    "action.receipt": "Квитанция",
    "action.executionPacket": "Пакет исполнения",
    "action.createCampaign": "Создать кампанию",
    "action.attributeAccount": "Привязать аккаунт",
    "action.reloadReports": "Обновить отчёты",
    "action.createInstruction": "Создать инструкцию",
    "action.detail": "Детали",
    "action.applyFilter": "Применить фильтр",
    "action.pollNow": "Опросить сейчас",
    "action.fundDemo": "Пополнить демо-аккаунт",
    "action.funding": "Пополнение...",
    "action.reviewOrder": "Проверить заявку",
    "action.submitQuote": "Отправить котировку",
    "label.workflow": "Процесс",
    "label.id": "ID",
    "label.account": "Аккаунт",
    "label.accountType": "Тип аккаунта",
    "label.state": "Состояние",
    "label.market": "Рынок",
    "label.lastPrice": "Последняя цена",
    "label.bidAsk": "Бид / аск",
    "label.volume": "Объём",
    "label.tickLot": "Шаг / лот",
    "label.feed": "Лента",
    "label.balances": "Балансы",
    "label.ledger": "Журнал",
    "label.trades": "Сделки",
    "label.accountData": "Данные аккаунта",
    "label.side": "Сторона",
    "label.quantity": "Количество",
    "label.price": "Цена",
    "label.target": "Цель",
    "label.status": "Статус",
    "label.quotes": "Котировки",
    "label.expiry": "Срок",
    "label.action": "Действие",
    "label.actions": "Действия",
    "label.comment": "Комментарий",
    "label.quote": "Котировка",
    "label.name": "Название",
    "label.code": "Код",
    "label.window": "Окно",
    "label.created": "Создано",
    "label.campaign": "Кампания",
    "label.campaignCode": "Код кампании",
    "label.month": "Месяц",
    "label.time": "Время",
    "label.trade": "Сделка",
    "label.accountRole": "Роль",
    "label.notional": "Номинал",
    "label.fee": "Комиссия",
    "label.rebate": "Возврат",
    "label.route": "Маршрут",
    "label.bucket": "Период",
    "label.trigger": "Триггер",
    "label.triggerPrice": "Цена триггера",
    "label.limitPrice": "Лимитная цена",
    "label.clientOrderId": "ID заявки клиента",
    "label.triggeredAt": "Сработала",
    "label.sequence": "№",
    "label.reason": "Основание",
    "label.events": "События",
    "label.last": "Последняя",
    "label.bestBid": "Лучший бид",
    "label.bestAsk": "Лучший аск",
    "label.orderSide": "Сторона заявки",
    "label.limit": "Лимит",
    "label.amount": "Сумма",
    "label.updated": "Обновлено",
    "label.origin": "Источник",
    "label.venue": "Площадка",
    "label.band": "Диапазон",
    "label.routing": "Маршрут",
    "label.feeTier": "Тариф",
    "label.bookingMarker": "Маркер расчёта",
    "label.bookingRef": "Ссылка расчёта",
    "label.venueRef": "Ссылка площадки",
    "label.aggressorSide": "Сторона агрессора",
    "label.orderType": "Тип заявки",
    "label.estimatedNotional": "Оценочный номинал",
    "label.originalFilledRemaining": "Исходное / исполнено / остаток",
    "label.asset": "Актив",
    "label.available": "Доступно",
    "label.locked": "Заблокировано",
    "label.total": "Итого",
    "label.type": "Тип",
    "label.source": "Источник",
    "label.remaining": "Остаток",
    "label.original": "Исходное",
    "label.filled": "Исполнено",
    "label.settlement": "Расчёт",
    "label.debit": "Списание",
    "label.credit": "Зачисление",
    "label.quoteAmount": "Сумма котировки",
    "label.orderId": "Заявка",
    "label.bookingSide": "Сторона расчёта",
    "label.deskSide": "Сторона площадки",
    "label.eligible": "Доступно",
    "label.alreadyQuoted": "Уже котировано",
    "label.deliveryTerms": "Условия расчёта",
    "label.boardComment": "Комментарий доски",
    "label.expiryTime": "Время истечения",
    "label.quotePrice": "Цена котировки",
    "label.quoteQuantity": "Количество котировки",
    "label.quoteExpiry": "Срок котировки UTC (необязательно)",
    "label.startsAt": "Начало UTC (необязательно)",
    "label.endsAt": "Окончание UTC (необязательно)",
    "label.userReference": "Ссылка пользователя (необязательно)",
    "label.publicFeedCursor": "Курсор ленты",
    "label.feedFilter": "Фильтр рынка",
    "label.allMarkets": "Все рынки",
    "view.coreTrade": "Основные торги",
    "view.portfolio": "Портфель",
    "view.rfqBoard": "Доска RFQ",
    "view.partnerDesk": "Партнёрский кабинет",
    "view.conditionalOrders": "Условные заявки",
    "view.publicFeed": "Публичная лента",
    "panel.orderBook": "Книга заявок",
    "panel.marketContext": "Контекст рынка",
    "panel.orderTicket": "Заявка",
    "panel.publicTrades": "Публичные сделки",
    "panel.openOrders": "Открытые заявки",
    "panel.wallets": "Балансы",
    "panel.ledger": "Журнал",
    "panel.orderHistory": "История заявок",
    "panel.executionsReceipts": "Исполнения и квитанции",
    "panel.rfqBoard": "Доска RFQ",
    "panel.createRfq": "Создать RFQ",
    "panel.rfqDetail": "Детали RFQ и котировка",
    "panel.partnerCampaigns": "Партнёрские кампании",
    "panel.partnerAttribution": "Партнёрская атрибуция",
    "panel.partnerReport": "Партнёрский отчёт",
    "panel.conditionalCreate": "Создать условную заявку",
    "panel.conditionalList": "Условные заявки",
    "panel.conditionalDetail": "Детали условной заявки",
    "panel.feedControl": "Управление лентой",
    "panel.feedEvents": "События ленты",
    "state.publicData": "Публичные данные",
    "state.synced": "Синхронизировано",
    "state.partial": "Частично",
    "state.loading": "Загрузка",
    "state.idle": "Ожидание",
    "state.signedOut": "Не выполнен вход",
    "state.polling": "Опрос",
    "state.stale": "Устарело",
    "state.unavailable": "Недоступно",
    "state.noBalances": "Нет балансов",
    "state.noTwoSidedMarket": "Нет двустороннего рынка",
    "state.noExpiry": "Без срока",
    "state.openWindow": "открыто",
    "state.notTriggered": "Не сработала",
    "state.unknownTrigger": "Неизвестный триггер",
    "state.liveEmpty": "Опрос · пусто",
    "state.catchingUp": "Синхронизация...",
    "copy.portfolioAuth":
      "Войдите, чтобы просматривать балансы, журнал, заявки, исполнения и квитанции.",
    "copy.authRequired": "Войдите, чтобы использовать этот рабочий процесс.",
    "copy.noOpenRfqs": "Для этого аккаунта нет видимых открытых RFQ.",
    "copy.noOwnerQuotes": "Пока нет котировок для инициатора.",
    "copy.selectRfq":
      "Выберите строку RFQ, чтобы открыть детали инициатора или доступность котировки.",
    "copy.rfqPublish":
      "Запросы котировок публикуют рынок, сторону, количество, целевую цену, комментарий и срок для вошедших пользователей биржи.",
    "copy.partnerOnly":
      "Управление кампаниями доступно партнёрским аккаунтам. Спотовые аккаунты могут привязаться ниже.",
    "copy.noPartnerCampaigns":
      "Для этого аккаунта партнёрские кампании не загружены.",
    "copy.attribution":
      "Привязка использует только текущий аккаунт и показывает партнёру ограниченные торговые факты по кампании.",
    "copy.partnerReportsForbiddenTitle":
      "Партнёрские отчёты требуют партнёрский аккаунт.",
    "copy.partnerReportsForbiddenBody":
      "Спотовые аккаунты и аккаунты ликвидности могут использовать привязку, но не просматривают партнёрские отчёты.",
    "copy.noMonthlyRows":
      "Нет месячных строк партнёрского отчёта для текущего фильтра.",
    "copy.noPartnerTradeRows":
      "Нет торговых строк партнёрского отчёта для текущего фильтра.",
    "copy.conditionalNotice":
      "Триггеры следят за последней публичной сделкой. Вариант «не ниже» подходит для импульса, вариант «не выше» - для отката. После обработки подходящего события инструкция становится размещённой или отклонённой.",
    "copy.noConditionalOrders": "Для этого аккаунта нет условных заявок.",
    "copy.selectConditional":
      "Выберите условную заявку, чтобы посмотреть её жизненный цикл.",
    "copy.conditionalLifecycle":
      "После обработки рыночного события здесь появятся статусы размещения или отклонения; срок ограничивает, до какого момента заявка может сработать.",
    "copy.feedNotice":
      "Опрос использует публичный последовательный курсор и добавляет новые события без повторов.",
    "copy.noFeedEvents": "В этом курсоре нет событий публичной ленты.",
    "copy.signInOrder":
      "Войдите, чтобы отправить заявку. Публичные рыночные данные остаются доступны.",
    "copy.orderTicket":
      "Заявки только лимитные. Проверка показывает сторону, рынок, количество, лимитную цену и оценочный номинал перед отправкой.",
    "copy.noOrderBook": "Книга заявок не загружена.",
    "copy.noOpenLiquidity": "Для этого рынка нет открытой ликвидности.",
    "copy.noCandles":
      "Публичных свечей пока нет. График появится после формирования свечей из сделок.",
    "copy.oneCandle":
      "Доступна одна свеча: закрытие {close}, объём {volume}. Для линейного графика нужно больше свечей.",
    "copy.candleSummary":
      "{count} реальных свечей {interval}. Первое закрытие {first}, последнее закрытие {last}.",
    "copy.candlesUnavailable":
      "Свечи недоступны. Показан только контекст тикера.",
    "copy.noPublicTrades": "Публичных сделок пока нет.",
    "copy.signInOrders": "Войдите, чтобы просмотреть свои заявки.",
    "copy.noOrders": "В этом аккаунте нет заявок.",
    "copy.noWallets":
      "Балансов пока нет. Используйте демо-пополнение, чтобы создать обычные балансы.",
    "copy.faucetNotice":
      "Демо-пополнение использует один идемпотентный ключ браузерного запроса. Повтор с тем же ключом не начисляет баланс дважды.",
    "copy.noLedger": "Движений журнала пока нет.",
    "copy.noOrderLifecycle": "Истории жизненного цикла заявок пока нет.",
    "copy.noExecutions":
      "Исполнений пока нет. Квитанции появятся после расчёта сделок.",
    "copy.orderReviewNotice":
      "Отправка этой инструкции может зарезервировать котируемый актив для покупки или базовый актив для продажи, если заявка будет принята.",
    "copy.cancelNotice":
      "Отмена запрашивает освобождение оставшегося зарезервированного объёма после подтверждения API.",
    "copy.ownerDetailSession":
      "Детали инициатора доступны для RFQ, открытых в этой сессии браузера. Для остальных видимых RFQ используйте рабочий просмотр.",
    "copy.ownerDetail404":
      "Детали инициатора недоступны для этого RFQ в текущей сессии. Рабочий просмотр остаётся доступным с доски.",
    "copy.ownerDetailLoadFailed":
      "Детали инициатора не удалось загрузить. Рабочий просмотр остаётся доступным с доски.",
    "copy.publicPanelsDegraded":
      "рыночных панелей работают с ограничениями. Уже загруженные панели доступны.",
    "copy.accountRegionsDegraded":
      "областей аккаунта работают с ограничениями. Уже загруженные области доступны.",
    "copy.advancedRegionsDegraded":
      "расширенных областей работают с ограничениями. Уже загруженные области доступны.",
    "copy.feedStale":
      "Опрос публичной ленты устарел. Уже полученные события остаются видимыми.",
    "auth.title": "Доступ к VoltaX",
    "auth.subtitle": "Используйте публичный биржевой аккаунт.",
    "auth.mode": "Режим",
    "auth.login": "Вход",
    "auth.register": "Регистрация",
    "auth.username": "Имя пользователя",
    "auth.password": "Пароль",
    "auth.accountType": "Тип аккаунта",
    "auth.signedIn": "Вход выполнен: {username}.",
    "auth.signedOut": "Сессия в браузере завершена.",
    "auth.sessionExpired": "Сессия истекла. Войдите снова, чтобы продолжить.",
    "auth.savedSessionExpired":
      "Сохранённая сессия истекла. Войдите снова, чтобы просмотреть данные аккаунта.",
    "error.generic": "Не удалось выполнить запрос.",
    "error.unauthorized": "Сессия отсутствует или истекла.",
    "error.invalidRequest":
      "Проверьте значения, шаг цены, размер лота и статус рынка.",
    "error.insufficientFunds":
      "Доступного баланса недостаточно для этой заявки.",
    "error.clientOrderIdTaken":
      "Этот ID заявки клиента уже используется в аккаунте.",
    "error.faucetAlreadyClaimed":
      "Демо-пополнение уже запрошено другим запросом.",
    "error.notFound": "Эта запись недоступна для аккаунта.",
    "error.forbidden": "Аккаунту недоступно это действие.",
    "error.campaignCodeTaken": "Этот код партнёрской кампании уже занят.",
    "error.campaignNotActive": "Эта партнёрская кампания не активна.",
    "error.attributionAlreadyExists": "Аккаунт уже привязан к этой кампании.",
    "error.quoteAlreadyExists": "Аккаунт уже отправил котировку для этого RFQ.",
    "error.rfqNotOpen": "Этот RFQ больше не открыт.",
    "error.quoteNotAcceptable":
      "Эту котировку нельзя принять в текущем состоянии.",
    "error.network": "API биржи недоступен. Попробуйте ещё раз.",
    "error.serviceUnavailable":
      "API биржи ещё не готов. Попробуйте немного позже.",
    "validation.market": "Выберите рынок.",
    "validation.limitPrice": "Введите положительную лимитную цену.",
    "validation.quantity": "Введите положительное количество.",
    "validation.clientOrderId": "ID заявки клиента слишком длинный.",
    "validation.price8":
      "Введите положительную цену с точностью до 8 знаков после запятой.",
    "validation.quantity8":
      "Введите положительное количество с точностью до 8 знаков после запятой.",
    "validation.pricePositive": "Цена должна быть больше нуля.",
    "validation.quantityPositive": "Количество должно быть больше нуля.",
    "validation.rfqExpiryRequired": "Для RFQ нужно выбрать будущий срок.",
    "validation.rfqExpiryValid": "Введите корректный будущий срок RFQ.",
    "validation.rfqExpiryFuture": "Срок RFQ должен быть в будущем.",
    "validation.rfqDeliveryTerms": "Введите условия расчёта для RFQ.",
    "msg.orderAccepted":
      "Заявка принята: {side} {quantity} {market} по {price}.",
    "msg.orderCancelAccepted": "Отмена заявки для {market} принята.",
    "msg.rfqOpened": "RFQ {id} открыт для {market}.",
    "msg.quoteSubmitted": "Котировка {quoteId} отправлена для RFQ {rfqId}.",
    "msg.rfqAccepted": "RFQ {rfqId} принял котировку {quoteId}.",
    "msg.campaignCreated": "Партнёрская кампания {code} создана.",
    "msg.accountAttributed": "Аккаунт привязан к {code}.",
    "msg.conditionalCreated": "Условная заявка {id} создана.",
    "msg.faucetReplay":
      "Запрос демо-пополнения повторён безопасно; баланс не начислен дважды.",
    "msg.faucetFunded": "Демо-пополнение принято; баланс и журнал обновлены.",
    "msg.faucetAlreadyFunded":
      "Демо-пополнение уже применено для этого аккаунта.",
    "msg.faucetUpdated": "Состояние демо-пополнения обновлено.",
    "dialog.reviewOrder": "Проверка лимитной заявки",
    "dialog.cancelOrder": "Отменить заявку?",
    "dialog.detailUnavailable": "Детали недоступны.",
    "dialog.executionPacket": "Пакет исполнения",
    "dialog.ownerReceipt": "Квитанция операции",
    "dialog.publicTrade": "Публичная сделка",
    "dialog.loadingDetail": "Загрузка: {title}...",
    "value.notProvided": "Не указано",
    "value.limit": "Лимитная",
    "value.unableToEstimate": "Не удалось оценить",
    "value.yes": "Да",
    "value.no": "Нет",
    "trigger.atOrAbove": "Последняя сделка не ниже триггера",
    "trigger.atOrBelow": "Последняя сделка не выше триггера",
  };
  function t(key, vars = {}) {
    let value = messages[key];
    for (const [name, replacement] of Object.entries(vars)) {
      value = value.replaceAll(`{${name}}`, String(replacement));
    }
    return value;
  }
  function countLabel(count, one, few, many) {
    const mod10 = Math.abs(count) % 10;
    const mod100 = Math.abs(count) % 100;
    const word =
      mod10 === 1 && mod100 !== 11
        ? one
        : mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)
          ? few
          : many;
    return `${count} ${word}`;
  }
  function sideLabel(side) {
    return mapLabel(side, {
      buy: "Покупка",
      sell: "Продажа",
    });
  }
  function statusLabel(status) {
    return mapLabel(status, {
      active: "Активен",
      open: "Открыта",
      submitted: "Отправлена",
      accepted: "Принята",
      pending: "Ожидает",
      triggered: "Сработала",
      rejected: "Отклонена",
      cancelled: "Отменена",
      canceled: "Отменена",
      filled: "Исполнена",
      partially_filled: "Частично исполнена",
      closed: "Закрыта",
      funded: "Пополнено",
      already_funded: "Уже пополнено",
    });
  }
  function accountTypeLabel(accountType) {
    return mapLabel(accountType, {
      spot: "Спотовый аккаунт",
      liquidity: "Ликвидность",
      partner: "Партнёрский кабинет",
      public: t("state.publicData"),
    });
  }
  function roleLabel(role) {
    return mapLabel(role, {
      maker: "Мейкер",
      taker: "Тейкер",
      rfq: "RFQ",
      orderbook: "Книга заявок",
      standard: "Стандарт",
      "zero-fee": "Без комиссии",
      none: "Нет",
      negotiated: "Согласовано",
      n_a: "н/д",
      "n/a": "н/д",
    });
  }
  function ledgerTypeLabel(type) {
    return mapLabel(type, {
      faucet_credit: "Демо-пополнение",
      lock: "Резерв",
      unlock: "Освобождение",
      spend: "Списание",
      release: "Освобождение",
      adjustment_reversal: "Корректировка",
    });
  }
  function eventTypeLabel(type) {
    return mapLabel(type, {
      market_tick: "Тик рынка",
      trade: "Сделка",
      trade_executed: "Сделка",
      market_signal_activated: "Сигнал активирован",
      conditional_order_expired: "Условная заявка истекла",
    });
  }
  function reasonLabel(reason) {
    return mapLabel(reason, {
      tick: "Обновление рынка",
      market_tick: "Обновление рынка",
      deterministic_tick: "Детерминированный тик",
      match: "Сопоставление",
      trade_executed: "Исполнение сделки",
      market_signal_activated: "Сигнал рынка",
      conditional_order_expired: "Истечение условной заявки",
    });
  }
  function loadStateLabel(state, signedIn = true) {
    if (state === "ready") return t("state.synced");
    if (state === "partial") return t("state.partial");
    if (state === "loading") return t("state.loading");
    if (state === "error") return t("state.unavailable");
    return signedIn ? t("state.idle") : t("state.signedOut");
  }
  function mapLabel(value, labels) {
    return labels[value] ?? value;
  }

  class ApiError extends Error {
    status;
    code;
    constructor(status, code) {
      super(code);
      this.status = status;
      this.code = code;
      this.name = "ApiError";
    }
  }
  class ApiClient {
    baseUrl;
    tokenProvider;
    fetcher;
    constructor(
      baseUrl = "",
      tokenProvider = () => null,
      fetcher = defaultFetch,
    ) {
      this.baseUrl = baseUrl;
      this.tokenProvider = tokenProvider;
      this.fetcher = fetcher;
    }
    async register(username, password, accountProfile) {
      return this.request("/api/auth/register", {
        method: "POST",
        body: { username, password, account_profile: accountProfile },
      });
    }
    async login(username, password) {
      return this.request("/api/auth/login", {
        method: "POST",
        body: { username, password },
      });
    }
    async me() {
      return this.request("/api/auth/me", { auth: true });
    }
    async markets() {
      return this.request("/api/markets");
    }
    async ticker(symbol) {
      return this.request(`/api/markets/${encodeURIComponent(symbol)}/ticker`);
    }
    async candles(symbol, interval = "1m", limit = 40) {
      return this.request(
        `/api/markets/${encodeURIComponent(symbol)}/candles?interval=${encodeURIComponent(interval)}&limit=${encodeURIComponent(String(limit))}`,
      );
    }
    async orderBook(symbol) {
      return this.request(
        `/api/markets/${encodeURIComponent(symbol)}/orderbook`,
      );
    }
    async publicTrades(symbol) {
      return this.request(`/api/markets/${encodeURIComponent(symbol)}/trades`);
    }
    async publicTradeDetail(id) {
      return this.request(`/api/trades/${encodeURIComponent(String(id))}`);
    }
    async wallets() {
      return this.request("/api/wallets", { auth: true });
    }
    async ledger() {
      return this.request("/api/ledger", { auth: true });
    }
    async faucet(idempotencyKey) {
      return this.request("/api/faucet", {
        method: "POST",
        body: { idempotency_key: idempotencyKey },
        auth: true,
      });
    }
    async orders() {
      return this.request("/api/orders", { auth: true });
    }
    async createOrder(input) {
      return this.request("/api/orders", {
        method: "POST",
        body: input,
        auth: true,
      });
    }
    async cancelOrder(id) {
      return this.request(`/api/orders/${id}`, {
        method: "DELETE",
        auth: true,
      });
    }
    async userTrades() {
      return this.request("/api/users/me/trades", { auth: true });
    }
    async tradeDetail(id) {
      return this.request(`/api/trades/${encodeURIComponent(String(id))}`, {
        auth: true,
      });
    }
    async tradeReceipt(id) {
      return this.request(
        `/api/trades/${encodeURIComponent(String(id))}/receipt`,
        { auth: true },
      );
    }
    async publicFeed(params = {}) {
      const query = new URLSearchParams();
      if (params.market_symbol)
        query.set("market_symbol", params.market_symbol);
      if (params.since_sequence !== undefined)
        query.set("since_sequence", String(params.since_sequence));
      if (params.after_sequence !== undefined)
        query.set("after_sequence", String(params.after_sequence));
      if (params.limit !== undefined) query.set("limit", String(params.limit));
      const suffix = query.toString() ? `?${query.toString()}` : "";
      return this.request(`/api/feed/public${suffix}`);
    }
    async createRfq(input) {
      const { delivery_terms, ...publicTerms } = input;
      const body = {
        ...publicTerms,
        delivery_terms: delivery_terms.trim(),
      };
      return this.request("/api/rfq", { method: "POST", body, auth: true });
    }
    async rfqBoard() {
      return this.request("/api/rfq/board", { auth: true });
    }
    async rfqDetail(id) {
      return this.request(`/api/rfq/${encodeURIComponent(String(id))}`, {
        auth: true,
      });
    }
    async rfqWorkup(id) {
      return this.request(`/api/rfq/${encodeURIComponent(String(id))}/workup`, {
        auth: true,
      });
    }
    async submitRfqQuote(id, input) {
      return this.request(`/api/rfq/${encodeURIComponent(String(id))}/quote`, {
        method: "POST",
        body: input,
        auth: true,
      });
    }
    async acceptRfqQuote(id, quoteId) {
      return this.request(`/api/rfq/${encodeURIComponent(String(id))}/accept`, {
        method: "POST",
        body: { quote_id: quoteId },
        auth: true,
      });
    }
    async brokerCampaigns() {
      return this.request("/api/broker/campaigns", { auth: true });
    }
    async createPartnerCampaign(input) {
      return this.request("/api/broker/campaigns", {
        method: "POST",
        body: input,
        auth: true,
      });
    }
    async createPartnerAttribution(input) {
      return this.request("/api/broker/attributions", {
        method: "POST",
        body: input,
        auth: true,
      });
    }
    async brokerTradeReports(params = {}) {
      const suffix = querySuffix(params);
      return this.request(`/api/broker/reports/trades${suffix}`, {
        auth: true,
      });
    }
    async brokerMonthlyReports(params = {}) {
      const suffix = querySuffix(params);
      return this.request(`/api/broker/reports/monthly${suffix}`, {
        auth: true,
      });
    }
    async conditionalOrders() {
      return this.request("/api/conditional-orders", { auth: true });
    }
    async conditionalOrder(id) {
      return this.request(
        `/api/conditional-orders/${encodeURIComponent(String(id))}`,
        { auth: true },
      );
    }
    async createConditionalOrder(input) {
      return this.request("/api/conditional-orders", {
        method: "POST",
        body: input,
        auth: true,
      });
    }
    async request(path, options = {}) {
      const headers = new Headers({ Accept: "application/json" });
      if (options.body !== undefined)
        headers.set("Content-Type", "application/json");
      if (options.auth) {
        const token = this.tokenProvider();
        if (!token) throw new ApiError(401, "unauthorized");
        headers.set("Authorization", `Bearer ${token}`);
      }
      const requestInit = { method: options.method ?? "GET", headers };
      if (options.body !== undefined)
        requestInit.body = JSON.stringify(options.body);
      let response;
      try {
        response = await this.fetcher(`${this.baseUrl}${path}`, requestInit);
      } catch {
        throw new ApiError(0, "network_error");
      }
      const payload = await response.json().catch(() => ({}));
      if (!response.ok) {
        const code =
          typeof payload.error === "string" ? payload.error : "request_failed";
        throw new ApiError(response.status, code);
      }
      return payload;
    }
  }
  function querySuffix(params) {
    const query = new URLSearchParams();
    Object.entries(params).forEach(([key, value]) => {
      if (value) query.set(key, value);
    });
    return query.toString() ? `?${query.toString()}` : "";
  }
  function defaultFetch(input, init) {
    if (typeof fetch === "function") return fetch(input, init);
    return xhrFetch(input, init);
  }
  function xhrFetch(input, init) {
    if (typeof XMLHttpRequest !== "function")
      return Promise.reject(new Error("network_unavailable"));
    return new Promise((resolve, reject) => {
      const request = new XMLHttpRequest();
      request.open(init.method ?? "GET", input);
      const headers =
        init.headers instanceof Headers
          ? init.headers
          : new Headers(init.headers);
      headers.forEach((value, key) => request.setRequestHeader(key, value));
      request.onload = () => {
        resolve({
          ok: request.status >= 200 && request.status < 300,
          status: request.status,
          json: async () =>
            request.responseText ? JSON.parse(request.responseText) : {},
        });
      };
      request.onerror = () => reject(new Error("network_error"));
      request.send(typeof init.body === "string" ? init.body : null);
    });
  }

  const TOKEN_KEY = "voltax.session.token";
  const USER_KEY = "voltax.session.user";
  function browserSessionStorage() {
    try {
      return globalThis.sessionStorage;
    } catch {
      return null;
    }
  }
  function loadSession(storage = browserSessionStorage()) {
    if (!storage) return null;
    let token = null;
    let userJson = null;
    try {
      token = storage.getItem(TOKEN_KEY);
      userJson = storage.getItem(USER_KEY);
    } catch {
      return null;
    }
    if (!token || !userJson) return null;
    try {
      const user = JSON.parse(userJson);
      if (!user?.username || !user?.account_profile) return null;
      return { token, user };
    } catch {
      return null;
    }
  }
  function saveSession(session, storage = browserSessionStorage()) {
    if (!storage) return;
    try {
      storage.setItem(TOKEN_KEY, session.token);
      storage.setItem(USER_KEY, JSON.stringify(session.user));
    } catch {}
  }
  function clearSession(storage = browserSessionStorage()) {
    if (!storage) return;
    try {
      storage.removeItem(TOKEN_KEY);
      storage.removeItem(USER_KEY);
    } catch {}
  }

  function compactDecimal(value, fallback = "-") {
    if (value == null || value === "") return fallback;
    const match = value.match(/^(-?\d+)(?:\.(\d+))?$/);
    if (!match) return value;
    const integer = match[1] ?? "0";
    const fraction = (match[2] ?? "").replace(/0+$/, "");
    return fraction ? `${integer}.${fraction}` : integer;
  }
  function formatUtcTime(value) {
    const date = new Date(value);
    if (Number.isNaN(date.getTime())) return value;
    return (
      new Intl.DateTimeFormat("en-GB", {
        hour: "2-digit",
        minute: "2-digit",
        second: "2-digit",
        timeZone: "UTC",
      }).format(date) + " UTC"
    );
  }

  const DECIMAL = /^\d+(?:\.\d+)?$/;
  function isPositiveDecimalString(value) {
    if (!DECIMAL.test(value)) return false;
    return value.replace(/[.0]/g, "").length > 0;
  }
  function validateOrder(input) {
    const errors = [];
    if (!input.market_symbol) errors.push(t("validation.market"));
    if (!isPositiveDecimalString(input.limit_price))
      errors.push(t("validation.limitPrice"));
    if (!isPositiveDecimalString(input.quantity))
      errors.push(t("validation.quantity"));
    if (
      input.client_order_id !== undefined &&
      input.client_order_id.length > 64
    )
      errors.push(t("validation.clientOrderId"));
    return errors;
  }

  function buildOrderReview(input, market) {
    return {
      side: input.side,
      market_symbol: input.market_symbol,
      order_type: input.order_type,
      limit_price: input.limit_price,
      quantity: input.quantity,
      client_order_id: input.client_order_id ?? null,
      base_asset: market?.base_asset ?? "base",
      quote_asset: market?.quote_asset ?? "quote",
      estimated_notional: multiplyDecimalStrings(
        input.limit_price,
        input.quantity,
      ),
    };
  }
  function multiplyDecimalStrings(left, right) {
    const a = decimalToUnits(left);
    const b = decimalToUnits(right);
    if (!a || !b) return null;
    const value = a.units * b.units;
    const scale = a.scale + b.scale;
    return formatUnits(value, scale);
  }
  function decimalToUnits(value) {
    const match = value.match(/^(\d+)(?:\.(\d+))?$/);
    if (!match) return null;
    const integer = match[1] ?? "0";
    const fraction = match[2] ?? "";
    return { units: BigInt(integer + fraction), scale: fraction.length };
  }
  function formatUnits(value, scale) {
    if (scale === 0) return value.toString();
    const raw = value.toString().padStart(scale + 1, "0");
    const integer = raw.slice(0, -scale);
    const fraction = raw.slice(-scale).replace(/0+$/, "");
    return fraction ? `${integer}.${fraction}` : integer;
  }

  function walletView(wallet) {
    return {
      asset: wallet.asset,
      available: compactDecimal(wallet.available_balance),
      locked: compactDecimal(wallet.locked_balance),
      total: addDecimalStrings(wallet.available_balance, wallet.locked_balance),
      updatedAt: formatUtcTime(wallet.updated_at),
    };
  }
  function ledgerEntryView(entry) {
    const direction = entry.amount.startsWith("-")
      ? "debit"
      : entry.amount === "0.00000000"
        ? "flat"
        : "credit";
    const source = [entry.reference_type, entry.reference_id]
      .filter(Boolean)
      .join(" · ");
    return {
      asset: entry.asset,
      bucket: entry.balance_bucket,
      amount: compactDecimal(entry.amount),
      direction,
      type: ledgerTypeLabel(entry.entry_type),
      source: source || "-",
      time: formatUtcTime(entry.created_at),
    };
  }
  function isOrderCancellable(order) {
    return (
      ["open", "partially_filled"].includes(order.status) &&
      order.remaining_quantity !== "0.00000000"
    );
  }
  function publicTradeFactView(trade) {
    return {
      tradeId: trade.trade_id ?? trade.id ?? null,
      market: trade.market_symbol,
      price: compactDecimal(trade.price),
      quantity: compactDecimal(trade.quantity),
      quoteAmount: compactDecimal(trade.quote_amount),
      aggressorSide: trade.aggressor_side
        ? sideLabel(String(trade.aggressor_side))
        : roleLabel("n/a"),
      time: formatUtcTime(trade.created_at),
    };
  }
  function participantTradeDetailView(trade) {
    const account = trade.account_booking;
    const venue = trade.venue_allocation;
    const view = publicTradeFactView(trade);
    if (account) {
      view.accountBooking = {
        tradeId: account.trade_id,
        orderId: account.order_id,
        clientOrderId: account.client_order_id ?? "-",
        bookingRef: account.booking_ref || "-",
        side: account.side,
        accountType: roleLabel(account.liquidity_role),
        settlementStatus: roleLabel(account.settlement_status),
      };
    }
    if (venue) {
      view.venueAllocation = {
        side: venue.side,
        accountType: roleLabel(venue.liquidity_role),
        settlementStatus: roleLabel(venue.settlement_status),
        deskRef: venue.desk_ref || "-",
      };
    }
    return view;
  }
  function ownerTradeSummaryView(trade) {
    return {
      tradeId: trade.id,
      market: trade.market_symbol,
      side: trade.side,
      accountType: roleLabel(trade.liquidity_role),
      clientOrderId: trade.client_order_id ?? "-",
      price: compactDecimal(trade.price),
      quantity: compactDecimal(trade.quantity),
      quoteAmount: compactDecimal(trade.quote_amount),
      debit: `${compactDecimal(trade.debit_amount)} ${trade.debit_asset}`,
      credit: `${compactDecimal(trade.credit_amount)} ${trade.credit_asset}`,
      fee: trade.fee_asset
        ? `${compactDecimal(trade.fee_amount)} ${trade.fee_asset}`
        : compactDecimal(trade.fee_amount),
      bookingRef: trade.booking_ref || "-",
      settlementStatus: roleLabel(trade.settlement_status),
      time: formatUtcTime(trade.created_at),
    };
  }
  function ownerReceiptView(receipt) {
    return {
      tradeId: receipt.trade_id,
      side: receipt.side,
      accountType: roleLabel(receipt.liquidity_role),
      market: receipt.market_symbol,
      clientOrderId: receipt.client_order_id ?? "-",
      price: compactDecimal(receipt.price),
      quantity: compactDecimal(receipt.quantity),
      quoteAmount: compactDecimal(receipt.quote_amount),
      debit: `${compactDecimal(receipt.debit_amount)} ${receipt.debit_asset}`,
      credit: `${compactDecimal(receipt.credit_amount)} ${receipt.credit_asset}`,
      fee: receipt.fee_asset
        ? `${compactDecimal(receipt.fee_amount)} ${receipt.fee_asset}`
        : compactDecimal(receipt.fee_amount),
      bookingRef: receipt.booking_ref || "-",
      settlementStatus: roleLabel(receipt.settlement_status),
      time: formatUtcTime(receipt.created_at),
    };
  }
  function faucetMessage(result) {
    if (result.replayed) return t("msg.faucetReplay");
    if (result.status === "funded") return t("msg.faucetFunded");
    if (result.status === "already_funded") return t("msg.faucetAlreadyFunded");
    return t("msg.faucetUpdated");
  }
  function addDecimalStrings(left, right) {
    const a = decimalToUnits(left);
    const b = decimalToUnits(right);
    if (!a || !b) return "-";
    const scale = Math.max(a.scale, b.scale);
    const value =
      a.units * 10n ** BigInt(scale - a.scale) +
      b.units * 10n ** BigInt(scale - b.scale);
    return compactDecimal(formatUnits(value, scale));
  }
  function decimalToUnits(value) {
    const match = value.match(/^(-?)(\d+)(?:\.(\d+))?$/);
    if (!match) return null;
    const sign = match[1] === "-" ? -1n : 1n;
    const integer = match[2] ?? "0";
    const fraction = match[3] ?? "";
    return { units: sign * BigInt(integer + fraction), scale: fraction.length };
  }
  function formatUnits(value, scale) {
    const sign = value < 0n ? "-" : "";
    const abs = value < 0n ? -value : value;
    if (scale === 0) return `${sign}${abs.toString()}`;
    const raw = abs.toString().padStart(scale + 1, "0");
    const integer = raw.slice(0, -scale);
    const fraction = raw.slice(-scale);
    return `${sign}${integer}.${fraction}`;
  }

  function rfqView(rfq) {
    return {
      id: rfq.id,
      market: rfq.market_symbol,
      side: rfq.side,
      quantity: compactDecimal(rfq.quantity),
      targetPrice: compactDecimal(rfq.target_price),
      status: rfq.status,
      quoteCount: String(rfq.quote_count ?? rfq.quotes?.length ?? 0),
      comment: rfq.public_comment || "-",
      expiresAt: rfq.expires_at
        ? formatUtcTime(rfq.expires_at)
        : t("state.noExpiry"),
      createdAt: formatUtcTime(rfq.created_at),
    };
  }
  function rfqQuoteView(quote) {
    return {
      id: quote.id,
      price: compactDecimal(quote.price),
      quantity: compactDecimal(quote.quantity),
      status: quote.status,
      expiresAt: quote.expires_at
        ? formatUtcTime(quote.expires_at)
        : t("state.noExpiry"),
    };
  }
  function rfqBoardActions(rfq, locallyOwnedRfqIds) {
    return {
      canOpenOwnerDetail: locallyOwnedRfqIds.has(rfq.id),
      canOpenWorkup: true,
    };
  }
  function rfqOwnerDetailUnavailableMessage(status = null) {
    if (status === 404) return t("copy.ownerDetail404");
    return t("copy.ownerDetailLoadFailed");
  }
  function brokerCampaignView(campaign) {
    const start = campaign.starts_at
      ? formatUtcTime(campaign.starts_at)
      : t("state.openWindow");
    const end = campaign.ends_at
      ? formatUtcTime(campaign.ends_at)
      : t("state.openWindow");
    return {
      id: campaign.id,
      code: campaign.campaign_code,
      name: campaign.name,
      status: campaign.status,
      window: `${start} / ${end}`,
      createdAt: formatUtcTime(campaign.created_at),
    };
  }
  function brokerTradeReportView(row) {
    return {
      campaign: row.campaign_code,
      tradeId: row.trade_id,
      market: row.market_symbol,
      side: row.side,
      accountType: row.liquidity_role,
      origin: row.origin,
      quantity: compactDecimal(row.quantity),
      executionPrice: compactDecimal(row.execution_price),
      notional: compactDecimal(row.notional_volume),
      fee: assetAmount(row.fee_amount, row.fee_asset),
      rebate: assetAmount(row.rebate_amount, row.rebate_asset),
      liquidityBand: roleLabel(row.liquidity_band || "standard"),
      venueCode: row.venue_code || "VX",
      feeTier: roleLabel(row.fee_tier || "zero-fee"),
      rebateHint: roleLabel(row.rebate_hint || "none"),
      routingLabel: roleLabel(row.routing_label || row.origin),
      bookingMarker: row.booking_marker || "-",
      time: formatUtcTime(row.traded_at),
      bucket: row.time_bucket,
    };
  }
  function brokerMonthlyReportView(row) {
    return {
      campaign: row.campaign_code,
      bucket: row.time_bucket,
      tradeCount: String(row.trade_count),
      notional: compactDecimal(row.total_notional_volume),
      fee: assetAmount(row.fee_amount, row.fee_asset),
      rebate: assetAmount(row.rebate_amount, row.rebate_asset),
    };
  }
  function triggerTypeLabel(triggerType) {
    if (triggerType === "last_trade_price_at_or_above")
      return t("trigger.atOrAbove");
    if (triggerType === "last_trade_price_at_or_below")
      return t("trigger.atOrBelow");
    return String(triggerType || t("state.unknownTrigger"));
  }
  function conditionalOrderView(order) {
    return {
      id: order.id,
      market: order.market_symbol,
      side: order.side,
      trigger: triggerTypeLabel(order.trigger_type),
      triggerPrice: compactDecimal(order.trigger_price),
      limitPrice: compactDecimal(order.limit_price),
      quantity: compactDecimal(order.quantity),
      status: order.status,
      clientOrderId: order.client_order_id || "-",
      expiresAt: order.expires_at
        ? formatUtcTime(order.expires_at)
        : t("state.noExpiry"),
      triggeredAt: order.triggered_at
        ? formatUtcTime(order.triggered_at)
        : t("state.notTriggered"),
      createdAt: formatUtcTime(order.created_at),
    };
  }
  function applyConditionalOrderRefresh(selected, orders) {
    return {
      orders,
      selected: selected
        ? (orders.find((order) => order.id === selected.id) ?? selected)
        : null,
    };
  }
  class SinglePoller {
    scheduler;
    intervalMs;
    timerId = null;
    constructor(scheduler, intervalMs) {
      this.scheduler = scheduler;
      this.intervalMs = intervalMs;
    }
    start(callback) {
      if (this.timerId !== null) return false;
      this.timerId = this.scheduler.setInterval(callback, this.intervalMs);
      return true;
    }
    stop() {
      if (this.timerId === null) return false;
      this.scheduler.clearInterval(this.timerId);
      this.timerId = null;
      return true;
    }
    get running() {
      return this.timerId !== null;
    }
  }
  function publicFeedEventView(event) {
    return {
      sequence: event.sequence,
      type: eventTypeLabel(event.event_type),
      market: event.market_symbol || "-",
      price: compactDecimal(event.price),
      quantity: compactDecimal(event.quantity),
      reason: event.public_reason ? reasonLabel(event.public_reason) : "-",
      time: formatUtcTime(event.created_at),
    };
  }
  function mergeFeedEvents(existing, incoming) {
    const seen = new Set(existing.map((event) => event.sequence));
    return [
      ...existing,
      ...incoming.filter((event) => !seen.has(event.sequence)),
    ].sort((left, right) => left.sequence - right.sequence);
  }
  function feedCursor(events) {
    return events.reduce((max, event) => Math.max(max, event.sequence), 0);
  }
  function recentFeedSinceSequence(nextSequence, limit = 100) {
    const tailSequence = Math.max(0, Math.trunc(Number(nextSequence ?? 1)) - 1);
    return Math.max(0, tailSequence - limit);
  }
  function publicFeedPollRequest(events, marketSymbol = "", limit = 100) {
    const request = { since_sequence: feedCursor(events), limit };
    if (marketSymbol) request.market_symbol = marketSymbol;
    return request;
  }
  async function bootstrapPublicFeed(
    fetchFeed,
    marketSymbol = "",
    limit = 100,
  ) {
    const base = marketSymbol ? { market_symbol: marketSymbol } : {};
    const probe = await fetchFeed({ ...base, since_sequence: 0, limit: 1 });
    const page = await fetchFeed({
      ...base,
      since_sequence: recentFeedSinceSequence(probe.next_sequence, limit),
      limit,
    });
    const events = mergeFeedEvents([], page.events);
    const result = { events, cursor: feedCursor(events) };
    const nextSequence = page.next_sequence ?? probe.next_sequence;
    if (nextSequence !== undefined) result.nextSequence = nextSequence;
    return result;
  }
  function publicFeedStatusLabel(state) {
    if (state.loading) return t("state.catchingUp");
    if (state.stale && state.cursor > 0)
      return `${t("state.stale")} · seq ${state.cursor}`;
    if (state.cursor > 0) return `${t("state.synced")} · seq ${state.cursor}`;
    return t("state.liveEmpty");
  }
  function validateDecimalInstruction(input) {
    const errors = [];
    const decimalPattern = /^(?:0|[1-9]\d*)(?:\.\d{1,8})?$/;
    if (input.price !== undefined && !decimalPattern.test(input.price))
      errors.push(t("validation.price8"));
    if (input.quantity !== undefined && !decimalPattern.test(input.quantity))
      errors.push(t("validation.quantity8"));
    if (input.price !== undefined && Number(input.price) <= 0)
      errors.push(t("validation.pricePositive"));
    if (input.quantity !== undefined && Number(input.quantity) <= 0)
      errors.push(t("validation.quantityPositive"));
    return errors;
  }
  function defaultRfqExpiryLocalValue(now = new Date()) {
    const expiry = new Date(now.getTime() + 15 * 60 * 1000);
    const local = new Date(
      expiry.getTime() - expiry.getTimezoneOffset() * 60_000,
    );
    return local.toISOString().slice(0, 16);
  }
  function validateRfqExpiryInput(value, now = new Date()) {
    const trimmed = value.trim();
    if (!trimmed)
      return { ok: false, error: t("validation.rfqExpiryRequired") };
    const timestamp = Date.parse(trimmed);
    if (!Number.isFinite(timestamp))
      return { ok: false, error: t("validation.rfqExpiryValid") };
    if (timestamp <= now.getTime())
      return { ok: false, error: t("validation.rfqExpiryFuture") };
    return { ok: true, isoUtc: new Date(timestamp).toISOString() };
  }
  function validateRfqCreateForm(values, now = new Date()) {
    const quantity = values.quantity.trim();
    const targetPrice = values.target_price.trim();
    const deliveryTerms = values.delivery_terms.trim();
    const errors = validateDecimalInstruction({ price: targetPrice, quantity });
    const expiry = validateRfqExpiryInput(values.expires_at, now);
    const expiresAt = expiry.ok ? expiry.isoUtc : null;
    if (!expiry.ok) errors.push(expiry.error);
    if (!deliveryTerms) errors.push(t("validation.rfqDeliveryTerms"));
    if (errors.length || !expiresAt) return { ok: false, errors };
    const publicComment = values.public_comment?.trim();
    const input = {
      market_symbol: values.market_symbol,
      side: values.side === "sell" ? "sell" : "buy",
      quantity,
      target_price: targetPrice,
      delivery_terms: deliveryTerms,
      expires_at: expiresAt,
    };
    if (publicComment) input.public_comment = publicComment;
    return { ok: true, input };
  }
  function assetAmount(amount, asset) {
    const compact = compactDecimal(amount);
    return asset ? `${compact} ${asset}` : compact;
  }

  const appElement = document.querySelector("#app");
  if (!appElement) throw new Error(t("app.mountMissing"));
  const app = appElement;
  const state = {
    activeView: "trade",
    session: loadSession(),
    markets: [],
    symbol: "VOLT-USDT",
    ticker: null,
    candles: [],
    book: null,
    trades: [],
    orders: [],
    wallets: [],
    ledgerEntries: [],
    userTrades: [],
    publicState: "idle",
    ordersState: "idle",
    accountState: "idle",
    actionState: "idle",
    publicErrors: {},
    accountErrors: {},
    message: null,
    acknowledgement: null,
    faucetNotice: null,
    faucetKey: null,
    orderSide: "buy",
    reviewOrder: null,
    cancelOrder: null,
    detailDialog: null,
    validationErrors: [],
    advancedState: "idle",
    advancedErrors: {},
    rfqs: [],
    selectedRfq: null,
    workup: null,
    rfqDetailNotice: null,
    brokerCampaigns: [],
    brokerTrades: [],
    brokerMonthly: [],
    brokerForbidden: false,
    conditionalOrders: [],
    selectedConditional: null,
    feedEvents: [],
    feedFilter: "",
    feedState: "idle",
    feedStale: false,
    feedLastLoadAt: null,
  };
  const api = new ApiClient("", () => state.session?.token ?? null);
  let feedTimer = null;
  const locallyOwnedRfqIds = new Set();
  const conditionalPoller = new SinglePoller(
    {
      setInterval: (callback, intervalMs) =>
        window.setInterval(callback, intervalMs),
      clearInterval: (timerId) => window.clearInterval(timerId),
    },
    2000,
  );
  function escapeHtml(value) {
    return String(value ?? "").replace(
      /[&<>'"]/g,
      (char) =>
        ({
          "&": "&amp;",
          "<": "&lt;",
          ">": "&gt;",
          "'": "&#39;",
          '"': "&quot;",
        })[char] ?? char,
    );
  }
  function html(value) {
    return escapeHtml(value);
  }
  function errorMessage(error) {
    if (!(error instanceof ApiError)) return t("error.generic");
    const messages = {
      unauthorized: t("error.unauthorized"),
      invalid_request: t("error.invalidRequest"),
      insufficient_funds: t("error.insufficientFunds"),
      client_order_id_taken: t("error.clientOrderIdTaken"),
      faucet_already_claimed: t("error.faucetAlreadyClaimed"),
      not_found: t("error.notFound"),
      forbidden: t("error.forbidden"),
      campaign_code_taken: t("error.campaignCodeTaken"),
      campaign_not_active: t("error.campaignNotActive"),
      attribution_already_exists: t("error.attributionAlreadyExists"),
      quote_already_exists: t("error.quoteAlreadyExists"),
      rfq_not_open: t("error.rfqNotOpen"),
      quote_not_acceptable: t("error.quoteNotAcceptable"),
      network_error: t("error.network"),
      service_unavailable: t("error.serviceUnavailable"),
    };
    return messages[error.code] ?? t("error.generic");
  }
  function selectedMarket() {
    return state.markets.find((market) => market.symbol === state.symbol);
  }
  function accountCan(capability) {
    if (state.session?.user.capabilities)
      return state.session.user.capabilities.includes(capability);
    const fallback = {
      spot: ["orders", "rfq_board", "broker_attribution"],
      liquidity: ["orders", "rfq_board", "rfq_quote", "broker_attribution"],
      partner: [
        "orders",
        "rfq_board",
        "broker_attribution",
        "broker_campaigns",
        "broker_reports",
      ],
    };
    return Boolean(
      state.session &&
      fallback[state.session.user.account_profile]?.includes(capability),
    );
  }
  function handleSessionError(error, recovery = t("auth.sessionExpired")) {
    if (error instanceof ApiError && error.status === 401) {
      logout(false);
      state.message = recovery;
      return true;
    }
    return false;
  }
  async function restoreSession() {
    if (!state.session) return;
    try {
      const response = await api.me();
      state.session = { token: state.session.token, user: response.user };
      saveSession(state.session);
    } catch (error) {
      handleSessionError(error, t("auth.savedSessionExpired"));
    }
  }
  async function loadPublic() {
    state.publicState = "loading";
    state.publicErrors = {};
    render();
    try {
      const markets = await api.markets();
      state.markets = markets.markets;
      if (
        !state.markets.some((market) => market.symbol === state.symbol) &&
        state.markets[0]
      )
        state.symbol = state.markets[0].symbol;
    } catch (error) {
      const message = errorMessage(error);
      state.publicState = "error";
      state.publicErrors = {
        ticker: message,
        candles: message,
        book: message,
        trades: message,
      };
      state.message = message;
      render();
      return;
    }
    const [ticker, candles, book, trades] = await Promise.allSettled([
      api.ticker(state.symbol),
      api.candles(state.symbol, "1m", 40),
      api.orderBook(state.symbol),
      api.publicTrades(state.symbol),
    ]);
    const errors = {};
    if (ticker.status === "fulfilled") state.ticker = ticker.value.ticker;
    else errors.ticker = errorMessage(ticker.reason);
    if (candles.status === "fulfilled") state.candles = candles.value.candles;
    else errors.candles = errorMessage(candles.reason);
    if (book.status === "fulfilled") state.book = book.value.orderbook;
    else errors.book = errorMessage(book.reason);
    if (trades.status === "fulfilled") state.trades = trades.value.trades;
    else errors.trades = errorMessage(trades.reason);
    state.publicErrors = errors;
    state.publicState = Object.keys(errors).length ? "partial" : "ready";
    render();
  }
  async function loadOrders() {
    if (!state.session) {
      state.orders = [];
      state.ordersState = "idle";
      return;
    }
    state.ordersState = "loading";
    render();
    try {
      state.orders = (await api.orders()).orders;
      state.ordersState = "ready";
    } catch (error) {
      state.ordersState = "error";
      if (!handleSessionError(error)) state.message = errorMessage(error);
    }
    render();
  }
  async function loadAccount() {
    if (!state.session) {
      state.wallets = [];
      state.ledgerEntries = [];
      state.userTrades = [];
      state.accountState = "idle";
      state.accountErrors = {};
      return;
    }
    state.accountState = "loading";
    state.accountErrors = {};
    render();
    const [wallets, ledger, userTrades] = await Promise.allSettled([
      api.wallets(),
      api.ledger(),
      api.userTrades(),
    ]);
    const errors = {};
    let expired = false;
    if (wallets.status === "fulfilled") state.wallets = wallets.value.wallets;
    else {
      expired = handleSessionError(wallets.reason) || expired;
      errors.wallets = errorMessage(wallets.reason);
    }
    if (ledger.status === "fulfilled")
      state.ledgerEntries = ledger.value.ledger_entries;
    else {
      expired = handleSessionError(ledger.reason) || expired;
      errors.ledger = errorMessage(ledger.reason);
    }
    if (userTrades.status === "fulfilled")
      state.userTrades = userTrades.value.trades;
    else {
      expired = handleSessionError(userTrades.reason) || expired;
      errors.userTrades = errorMessage(userTrades.reason);
    }
    if (expired) return;
    state.accountErrors = errors;
    state.accountState = Object.keys(errors).length ? "partial" : "ready";
    render();
  }
  async function loadRfq() {
    if (!state.session) return;
    state.advancedState = "loading";
    delete state.advancedErrors.rfq;
    render();
    try {
      state.rfqs = (await api.rfqBoard()).rfqs;
      state.advancedState = "ready";
    } catch (error) {
      if (handleSessionError(error)) return;
      state.advancedErrors.rfq = errorMessage(error);
      state.advancedState = "error";
    }
    render();
  }
  async function loadPartner(params = {}) {
    if (!state.session) return;
    state.advancedState = "loading";
    delete state.advancedErrors.broker;
    state.brokerForbidden = false;
    render();
    const [campaigns, trades, monthly] = await Promise.allSettled([
      api.brokerCampaigns(),
      api.brokerTradeReports(params),
      api.brokerMonthlyReports(params),
    ]);
    const errors = [];
    if (campaigns.status === "fulfilled")
      state.brokerCampaigns = campaigns.value.campaigns;
    else {
      if (handleSessionError(campaigns.reason)) return;
      state.brokerForbidden =
        campaigns.reason instanceof ApiError && campaigns.reason.status === 403;
      errors.push(errorMessage(campaigns.reason));
    }
    if (trades.status === "fulfilled") state.brokerTrades = trades.value.trades;
    else {
      if (handleSessionError(trades.reason)) return;
      state.brokerForbidden =
        state.brokerForbidden ||
        (trades.reason instanceof ApiError && trades.reason.status === 403);
      errors.push(errorMessage(trades.reason));
    }
    if (monthly.status === "fulfilled")
      state.brokerMonthly = monthly.value.monthly;
    else {
      if (handleSessionError(monthly.reason)) return;
      state.brokerForbidden =
        state.brokerForbidden ||
        (monthly.reason instanceof ApiError && monthly.reason.status === 403);
      errors.push(errorMessage(monthly.reason));
    }
    if (errors.length)
      state.advancedErrors.broker = Array.from(new Set(errors)).join(" ");
    state.advancedState = errors.length ? "partial" : "ready";
    render();
  }
  async function loadConditional(background = false) {
    if (!state.session) return;
    const previousOrders = conditionalOrdersSignature(state.conditionalOrders);
    const previousSelected = conditionalOrderSignature(
      state.selectedConditional,
    );
    const hadError = Boolean(state.advancedErrors.conditional);
    if (!background) {
      state.advancedState = "loading";
      delete state.advancedErrors.conditional;
      render();
    }
    try {
      const refreshed = applyConditionalOrderRefresh(
        state.selectedConditional,
        (await api.conditionalOrders()).conditional_orders,
      );
      state.conditionalOrders = refreshed.orders;
      state.selectedConditional = refreshed.selected;
      delete state.advancedErrors.conditional;
      state.advancedState = "ready";
      const changed =
        previousOrders !==
          conditionalOrdersSignature(state.conditionalOrders) ||
        previousSelected !==
          conditionalOrderSignature(state.selectedConditional);
      if (!background || changed || hadError) render();
    } catch (error) {
      if (handleSessionError(error)) return;
      if (!background || state.conditionalOrders.length === 0) {
        state.advancedErrors.conditional = errorMessage(error);
        state.advancedState = state.conditionalOrders.length
          ? "partial"
          : "error";
        render();
      }
    }
  }
  function conditionalOrdersSignature(orders) {
    return orders.map(conditionalOrderSignature).join("|");
  }
  function conditionalOrderSignature(order) {
    if (!order) return "";
    return [
      order.id,
      order.status,
      order.updated_at ?? "",
      order.triggered_at ?? "",
      order.cancelled_at ?? "",
    ].join(":");
  }
  async function loadFeed(reset = false) {
    state.feedState = "loading";
    delete state.advancedErrors.feed;
    state.feedStale = false;
    if (reset) state.feedEvents = [];
    render();
    try {
      if (reset || state.feedEvents.length === 0) {
        const response = await bootstrapPublicFeed(
          (params) => api.publicFeed(params),
          state.feedFilter,
          100,
        );
        state.feedEvents = response.events;
      } else {
        const response = await api.publicFeed(
          publicFeedPollRequest(state.feedEvents, state.feedFilter, 100),
        );
        state.feedEvents = mergeFeedEvents(state.feedEvents, response.events);
      }
      state.feedLastLoadAt = Date.now();
      state.feedState = "ready";
    } catch (error) {
      state.advancedErrors.feed = errorMessage(error);
      state.feedStale = state.feedEvents.length > 0;
      state.feedState = state.feedEvents.length ? "partial" : "error";
    }
    render();
  }
  function logout(showMessage = true) {
    stopConditionalPolling();
    clearSession();
    locallyOwnedRfqIds.clear();
    state.session = null;
    state.orders = [];
    state.wallets = [];
    state.ledgerEntries = [];
    state.userTrades = [];
    state.rfqs = [];
    state.selectedRfq = null;
    state.workup = null;
    state.rfqDetailNotice = null;
    state.brokerCampaigns = [];
    state.brokerTrades = [];
    state.brokerMonthly = [];
    state.conditionalOrders = [];
    state.selectedConditional = null;
    state.ordersState = "idle";
    state.accountState = "idle";
    state.advancedState = "idle";
    state.accountErrors = {};
    state.advancedErrors = {};
    state.reviewOrder = null;
    state.cancelOrder = null;
    state.detailDialog = null;
    if (showMessage) state.message = t("auth.signedOut");
    render();
  }
  function render() {
    app.innerHTML = `
    <div class="app-shell ${state.actionState !== "idle" ? "is-busy" : ""}" aria-busy="${state.actionState !== "idle"}">
      ${topbar()}
      <div class="voltage-rail ${activeRailState()}" aria-reserved="true"></div>
      ${rail()}
      ${statusStrip()}
      ${workspace()}
    </div>
    ${state.message ? messageDialog() : ""}
    ${state.reviewOrder ? orderReviewDialog(state.reviewOrder) : ""}
    ${state.cancelOrder ? cancelReviewDialog(state.cancelOrder) : ""}
    ${state.detailDialog ? detailDialog() : ""}
  `;
    applyTableLabels(app);
    bindEvents();
  }
  function activeRailState() {
    if (state.activeView === "portfolio") return state.accountState;
    if (state.activeView === "trade") return state.publicState;
    if (state.activeView === "feed") return state.feedState;
    return state.advancedState;
  }
  function rail() {
    if (state.activeView === "trade") return marketRail();
    if (state.activeView === "portfolio") return accountRail();
    return advancedRail();
  }
  function workspace() {
    if (state.activeView === "trade") return tradeWorkspace();
    if (state.activeView === "portfolio") return portfolioWorkspace();
    if (state.activeView === "rfq") return rfqWorkspace();
    if (state.activeView === "broker") return brokerWorkspace();
    if (state.activeView === "automation") return automationWorkspace();
    return feedWorkspace();
  }
  function topbar() {
    const accountLabel = state.session
      ? `${state.session.user.username} · ${accountTypeLabel(state.session.user.account_profile)}`
      : t("state.publicData");
    return `
    <header class="topbar">
      <div class="brand" aria-label="${t("app.title")}">Volta<span class="brand-mark">X</span></div>
      <nav class="nav" aria-label="${t("aria.primary")}">
        ${navButton("trade", t("nav.trade"))}
        ${navButton("portfolio", t("nav.portfolio"))}
        ${navButton("rfq", "RFQ")}
        ${navButton("broker", t("nav.partner"))}
        ${navButton("automation", t("nav.automation"))}
        ${navButton("feed", t("nav.feed"))}
      </nav>
      <div class="account">
        ${state.session ? `<span class="account-chip" title="${escapeHtml(accountLabel)}" aria-label="${escapeHtml(accountLabel)}">${escapeHtml(accountLabel)}</span><button class="secondary" data-action="logout">${t("action.signOut")}</button>` : `<span class="account-chip muted" title="${escapeHtml(accountLabel)}" aria-label="${escapeHtml(accountLabel)}">${escapeHtml(accountLabel)}</span><button class="secondary" data-action="open-auth">${t("action.signIn")}</button>`}
      </div>
    </header>
  `;
  }
  function navButton(view, label) {
    const active = state.activeView === view;
    return `<button class="${active ? "active" : ""}" data-view="${view}" type="button" ${active ? `aria-current="page"` : ""}>${label}</button>`;
  }
  function advancedRail() {
    const accountType = accountTypeLabel(
      state.session?.user.account_profile ?? "public",
    );
    const advancedStatus = loadStateLabel(
      state.advancedState,
      Boolean(state.session),
    );
    const feedStatus =
      state.feedState === "ready"
        ? state.feedStale
          ? t("state.stale")
          : t("state.polling")
        : loadStateLabel(state.feedState);
    return `
    <section class="market-rail account-rail" aria-label="${t("aria.advancedSummary")}">
      <div class="cell"><span class="label">${t("label.workflow")}</span><span class="value">${escapeHtml(advancedTitle())}</span></div>
      <div class="cell"><span class="label">${t("label.accountType")}</span><span class="value">${escapeHtml(accountType)}</span></div>
      <div class="cell optional"><span class="label">RFQ</span><span class="value">${countLabel(state.rfqs.length, "строка", "строки", "строк")}</span></div>
      <div class="cell optional"><span class="label">${t("view.conditionalOrders")}</span><span class="value">${countLabel(state.conditionalOrders.length, "инструкция", "инструкции", "инструкций")}</span></div>
      <div class="cell optional"><span class="label">${t("label.publicFeedCursor")}</span><span class="value">${feedCursor(state.feedEvents)}</span></div>
      <div class="cell"><span class="label">${t("label.state")}</span><span class="feed-state ${state.activeView === "feed" ? state.feedState : state.advancedState}">${escapeHtml(state.activeView === "feed" ? feedStatus : advancedStatus)}</span></div>
    </section>
  `;
  }
  function advancedTitle() {
    const titles = {
      trade: t("view.coreTrade"),
      portfolio: t("view.portfolio"),
      rfq: t("view.rfqBoard"),
      broker: t("view.partnerDesk"),
      automation: t("view.conditionalOrders"),
      feed: t("view.publicFeed"),
    };
    return titles[state.activeView];
  }
  function marketRail() {
    const ticker = state.ticker;
    const market = selectedMarket();
    const spread =
      ticker?.best_bid && ticker?.best_ask
        ? `${compactDecimal(ticker.best_bid)} / ${compactDecimal(ticker.best_ask)}`
        : t("state.noTwoSidedMarket");
    const status = loadStateLabel(state.publicState);
    return `
    <section class="market-rail" aria-label="${t("aria.marketSummary")}">
      <div class="cell market-cell"><span class="label">${t("label.market")}</span><select id="market-select" aria-label="${t("label.market")}">${marketOptions()}</select></div>
      <div class="cell"><span class="label">${t("label.lastPrice")}</span><span class="value">${compactDecimal(ticker?.last_price)}</span></div>
      <div class="cell"><span class="label">${t("label.bidAsk")}</span><span class="value">${escapeHtml(spread)}</span></div>
      <div class="cell optional"><span class="label">${t("label.volume")}</span><span class="value">${compactDecimal(ticker?.volume)}</span></div>
      <div class="cell optional"><span class="label">${t("label.tickLot")}</span><span class="value">${compactDecimal(market?.tick_size)} / ${compactDecimal(market?.lot_size)}</span></div>
      <div class="cell"><span class="label">${t("label.feed")}</span><span class="feed-state ${state.publicState}">${html(status)}</span></div>
    </section>
  `;
  }
  function accountRail() {
    const walletTotal = state.wallets.length
      ? countLabel(state.wallets.length, "актив", "актива", "активов")
      : t("state.noBalances");
    const ledgerTotal = countLabel(
      state.ledgerEntries.length,
      "запись",
      "записи",
      "записей",
    );
    const tradeTotal = countLabel(
      state.userTrades.length,
      "исполнение",
      "исполнения",
      "исполнений",
    );
    const accountType = accountTypeLabel(
      state.session?.user.account_profile ?? "public",
    );
    const status = loadStateLabel(state.accountState, Boolean(state.session));
    return `
    <section class="market-rail account-rail" aria-label="${t("aria.accountSummary")}">
      <div class="cell"><span class="label">${t("label.account")}</span><span class="value">${escapeHtml(state.session?.user.username ?? t("action.signIn"))}</span></div>
      <div class="cell"><span class="label">${t("label.accountType")}</span><span class="value">${escapeHtml(accountType)}</span></div>
      <div class="cell"><span class="label">${t("label.balances")}</span><span class="value">${escapeHtml(walletTotal)}</span></div>
      <div class="cell optional"><span class="label">${t("label.ledger")}</span><span class="value">${escapeHtml(ledgerTotal)}</span></div>
      <div class="cell optional"><span class="label">${t("label.trades")}</span><span class="value">${escapeHtml(tradeTotal)}</span></div>
      <div class="cell"><span class="label">${t("label.accountData")}</span><span class="feed-state ${state.accountState}">${escapeHtml(status)}</span></div>
    </section>
  `;
  }
  function statusStrip() {
    const publicFailed = Object.values(state.publicErrors).filter(
      Boolean,
    ).length;
    const accountFailed = Object.values(state.accountErrors).filter(
      Boolean,
    ).length;
    const advancedFailed = Object.values(state.advancedErrors).filter(
      Boolean,
    ).length;
    const acknowledgement = state.acknowledgement
      ? `<div class="ack" role="status">${escapeHtml(state.acknowledgement)}</div>`
      : "";
    const faucet = state.faucetNotice
      ? `<div class="ack" role="status">${escapeHtml(state.faucetNotice)}</div>`
      : "";
    const partial =
      state.activeView === "trade" && publicFailed
        ? `<div class="strip-warning" role="status">${publicFailed} ${t("copy.publicPanelsDegraded")}</div>`
        : state.activeView === "portfolio" && accountFailed
          ? `<div class="strip-warning" role="status">${accountFailed} ${t("copy.accountRegionsDegraded")}</div>`
          : ["rfq", "broker", "automation"].includes(state.activeView) &&
              advancedFailed
            ? `<div class="strip-warning" role="status">${advancedFailed} ${t("copy.advancedRegionsDegraded")}</div>`
            : state.activeView === "feed" && state.feedStale
              ? `<div class="strip-warning" role="status">${t("copy.feedStale")}</div>`
              : "";
    return `<section class="status-strip" aria-label="${t("aria.workflowStatus")}" aria-live="polite">${acknowledgement}${faucet}${partial}</section>`;
  }
  function tradeWorkspace() {
    return `<main id="main" class="workspace">${orderBookPanel()}${marketContextPanel()}${orderTicketPanel()}${tradesPanel()}${ordersPanel()}</main>`;
  }
  function portfolioWorkspace() {
    if (!state.session) {
      return `<main id="main" class="portfolio-workspace">${panel(t("view.portfolio"), "portfolio-auth", `<div class="state"><strong>${t("copy.portfolioAuth")}</strong><button class="primary" data-action="open-auth">${t("action.signIn")}</button></div>`)}</main>`;
    }
    return `<main id="main" class="portfolio-workspace">${walletsPanel()}${ledgerPanel()}${orderHistoryPanel()}${userTradesPanel()}</main>`;
  }
  function authRequiredWorkspace(title) {
    return `<main id="main" class="advanced-workspace">${panel(title, "advanced-auth", `<div class="state"><strong>${t("copy.authRequired")}</strong><button class="primary" data-action="open-auth">${t("action.signIn")}</button></div>`)}</main>`;
  }
  function rfqWorkspace() {
    if (!state.session) return authRequiredWorkspace("RFQ");
    return `<main id="main" class="advanced-workspace">${rfqBoardPanel()}${rfqCreatePanel()}${rfqDetailPanel()}</main>`;
  }
  function brokerWorkspace() {
    if (!state.session) return authRequiredWorkspace(t("view.partnerDesk"));
    return `<main id="main" class="advanced-workspace">${brokerCampaignPanel()}${brokerAttributionPanel()}${brokerReportPanel()}</main>`;
  }
  function automationWorkspace() {
    if (!state.session)
      return authRequiredWorkspace(t("view.conditionalOrders"));
    return `<main id="main" class="advanced-workspace">${conditionalCreatePanel()}${conditionalListPanel()}${conditionalDetailPanel()}</main>`;
  }
  function feedWorkspace() {
    return `<main id="main" class="advanced-workspace feed-workspace">${feedControlPanel()}${feedEventsPanel()}</main>`;
  }
  function rfqBoardPanel() {
    if (state.advancedState === "loading" && !state.rfqs.length)
      return panel(
        t("panel.rfqBoard"),
        "advanced-wide",
        `<div class="state">Загрузка открытых RFQ...</div>`,
      );
    if (state.advancedErrors.rfq && !state.rfqs.length)
      return panel(
        t("panel.rfqBoard"),
        "advanced-wide",
        retryState(
          "Доска RFQ недоступна.",
          state.advancedErrors.rfq,
          "reload-rfq",
          "Повторить RFQ",
        ),
      );
    const rows = state.rfqs
      .map((rfq) => {
        const view = rfqView(rfq);
        const actions = rfqBoardActions(rfq, locallyOwnedRfqIds);
        const ownerAction = actions.canOpenOwnerDetail
          ? `<button class="secondary" data-rfq-detail="${view.id}">${t("action.ownerDetail")}</button>`
          : "";
        const workupAction = actions.canOpenWorkup
          ? `<button class="secondary" data-rfq-workup="${view.id}">${t("action.workup")}</button>`
          : "";
        return `<tr><td>${view.id}</td><td>${escapeHtml(view.market)}</td><td><span class="side-tag ${view.side === "buy" ? "bid" : "ask"}">${escapeHtml(sideLabel(view.side))}</span></td><td>${escapeHtml(view.quantity)}</td><td>${escapeHtml(view.targetPrice)}</td><td>${html(statusLabel(view.status))}</td><td>${escapeHtml(view.quoteCount)}</td><td>${escapeHtml(view.expiresAt)}</td><td>${[ownerAction, workupAction].filter(Boolean).join(" ")}</td></tr>`;
      })
      .join("");
    return panel(
      t("panel.rfqBoard"),
      "advanced-wide",
      rows
        ? `<div class="table-wrap"><table class="table dense-table"><thead><tr><th>RFQ</th><th>${t("label.market")}</th><th>${t("label.side")}</th><th>${t("label.quantity")}</th><th>${t("label.target")}</th><th>${t("label.status")}</th><th>${t("label.quotes")}</th><th>${t("label.expiry")}</th><th>${t("label.action")}</th></tr></thead><tbody>${rows}</tbody></table></div>`
        : `<div class="state">${t("copy.noOpenRfqs")}</div>`,
    );
  }
  function rfqCreatePanel() {
    const disabled = state.actionState !== "idle";
    const defaultExpiry = defaultRfqExpiryLocalValue();
    return panel(
      t("panel.createRfq"),
      "advanced-side",
      `
    <div class="panel-body">
      <form id="rfq-form" class="form-grid">
        <div class="field"><label for="rfq-market">${t("label.market")}</label><select id="rfq-market" name="market_symbol">${marketOptions()}</select></div>
        <div class="field"><label for="rfq-side">${t("label.side")}</label><select id="rfq-side" name="side"><option value="buy">${sideLabel("buy")}</option><option value="sell">${sideLabel("sell")}</option></select></div>
        <div class="field"><label for="rfq-quantity">${t("label.quantity")}</label><input id="rfq-quantity" name="quantity" inputmode="decimal" autocomplete="off" required placeholder="2.0000"></div>
        <div class="field"><label for="rfq-target-price">${t("label.target")}</label><input id="rfq-target-price" name="target_price" inputmode="decimal" autocomplete="off" required placeholder="10.00"></div>
        <div class="field"><label for="rfq-delivery-terms">${t("label.deliveryTerms")}</label><input id="rfq-delivery-terms" name="delivery_terms" maxlength="240" autocomplete="off" required value="стандартные условия RFQ"></div>
        <div class="field"><label for="rfq-comment">${t("label.boardComment")}</label><input id="rfq-comment" name="public_comment" maxlength="160" autocomplete="off" placeholder="видимая заметка, необязательно"></div>
        <div class="field"><label for="rfq-expires">${t("label.expiryTime")}</label><input id="rfq-expires" name="expires_at" type="datetime-local" required value="${escapeHtml(defaultExpiry)}"></div>
        <button class="primary" type="submit" ${disabled ? "disabled" : ""}>${state.actionState === "submitting" ? "Создание..." : t("panel.createRfq")}</button>
      </form>
      <p class="microcopy">${t("copy.rfqPublish")}</p>
    </div>
  `,
    );
  }
  function rfqDetailPanel() {
    const workup = state.workup ? rfqView(state.workup) : null;
    const owner = state.selectedRfq ? rfqView(state.selectedRfq) : null;
    const ownerQuotes = state.selectedRfq?.quotes ?? [];
    const ownerRows = ownerQuotes
      .map((quote) => {
        const view = rfqQuoteView(quote);
        const canAccept =
          state.selectedRfq?.status === "open" && view.status === "submitted";
        return `<tr><td>${view.id}</td><td>${escapeHtml(view.price)}</td><td>${escapeHtml(view.quantity)}</td><td>${escapeHtml(statusLabel(view.status))}</td><td>${escapeHtml(view.expiresAt)}</td><td>${canAccept ? `<button class="secondary" data-rfq-accept="${view.id}">${t("action.accept")}</button>` : "-"}</td></tr>`;
      })
      .join("");
    const ownerBlock = owner
      ? `<section class="subsection"><h3>${t("action.ownerDetail")}</h3><dl class="review-grid"><dt>RFQ</dt><dd>${owner.id}</dd><dt>${t("label.market")}</dt><dd>${escapeHtml(owner.market)}</dd><dt>${t("label.side")}</dt><dd><span class="side-tag ${owner.side === "buy" ? "bid" : "ask"}">${escapeHtml(sideLabel(owner.side))}</span></dd><dt>${t("label.quantity")}</dt><dd>${escapeHtml(owner.quantity)}</dd><dt>${t("label.target")}</dt><dd>${escapeHtml(owner.targetPrice)}</dd><dt>${t("label.status")}</dt><dd>${html(statusLabel(owner.status))}</dd><dt>${t("label.comment")}</dt><dd>${html(owner.comment)}</dd><dt>${t("label.expiry")}</dt><dd>${escapeHtml(owner.expiresAt)}</dd></dl>${ownerRows ? `<div class="table-wrap"><table class="table"><thead><tr><th>${t("label.quote")}</th><th>${t("label.price")}</th><th>${t("label.quantity")}</th><th>${t("label.status")}</th><th>${t("label.expiry")}</th><th>${t("label.action")}</th></tr></thead><tbody>${ownerRows}</tbody></table></div>` : `<div class="state compact-state">${t("copy.noOwnerQuotes")}</div>`}</section>`
      : "";
    const workupBlock =
      workup && state.workup
        ? `<section class="subsection"><h3>${t("action.workup")}</h3><dl class="review-grid"><dt>RFQ</dt><dd>${workup.id}</dd><dt>${t("label.market")}</dt><dd>${escapeHtml(workup.market)}</dd><dt>${t("label.side")}</dt><dd>${escapeHtml(sideLabel(workup.side))}</dd><dt>${t("label.quantity")}</dt><dd>${escapeHtml(workup.quantity)}</dd><dt>${t("label.status")}</dt><dd>${escapeHtml(statusLabel(workup.status))}</dd><dt>${t("label.alreadyQuoted")}</dt><dd>${state.workup.already_quoted ? t("value.yes") : t("value.no")}</dd><dt>${t("label.eligible")}</dt><dd>${state.workup.eligible_to_quote ? t("value.yes") : t("value.no")}</dd></dl>${rfqQuoteForm(state.workup.id)}</section>`
        : "";
    const noticeBlock = state.rfqDetailNotice
      ? `<div class="state compact-state">${escapeHtml(state.rfqDetailNotice)}</div>`
      : "";
    const body =
      ownerBlock || workupBlock || noticeBlock
        ? `<div class="panel-body panel-stack">${noticeBlock}${ownerBlock}${workupBlock}</div>`
        : `<div class="state">${t("copy.selectRfq")}</div>`;
    return panel(t("panel.rfqDetail"), "advanced-side", body);
  }
  function rfqQuoteForm(rfqId) {
    const disabled =
      state.actionState !== "idle" ||
      !state.workup?.eligible_to_quote ||
      state.workup?.already_quoted;
    return `<form id="rfq-quote-form" class="form-grid" data-rfq-id="${rfqId}">
    <div class="field"><label for="rfq-quote-price">${t("label.quotePrice")}</label><input id="rfq-quote-price" name="price" inputmode="decimal" autocomplete="off" required placeholder="10.00"></div>
    <div class="field"><label for="rfq-quote-quantity">${t("label.quoteQuantity")}</label><input id="rfq-quote-quantity" name="quantity" inputmode="decimal" autocomplete="off" required value="${escapeHtml(state.workup?.quantity ?? "")}"></div>
    <div class="field"><label for="rfq-quote-expires">${t("label.quoteExpiry")}</label><input id="rfq-quote-expires" name="expires_at" autocomplete="off" placeholder="2026-09-10T12:00:00Z"></div>
    <button class="primary" type="submit" ${disabled ? "disabled" : ""}>${state.actionState === "submitting" ? t("action.submitting") : "Отправить котировку"}</button>
  </form>`;
  }
  function brokerCampaignPanel() {
    const rows = state.brokerCampaigns
      .map((campaign) => {
        const view = brokerCampaignView(campaign);
        return `<tr><td>${view.id}</td><td class="clip-cell">${escapeHtml(view.code)}</td><td>${escapeHtml(view.name)}</td><td>${escapeHtml(statusLabel(view.status))}</td><td>${escapeHtml(view.window)}</td><td>${escapeHtml(view.createdAt)}</td></tr>`;
      })
      .join("");
    const forbidden = state.brokerForbidden
      ? `<p class="notice">${t("copy.partnerOnly")}</p>`
      : "";
    const formDisabled =
      !accountCan("broker_campaigns") || state.actionState !== "idle";
    return panel(
      t("panel.partnerCampaigns"),
      "advanced-side",
      `<div class="panel-body panel-stack">${forbidden}<form id="broker-campaign-form" class="form-grid"><div class="field"><label for="campaign-code">${t("label.campaignCode")}</label><input id="campaign-code" name="campaign_code" autocomplete="off" required placeholder="alpha-campaign"></div><div class="field"><label for="campaign-name">${t("label.name")}</label><input id="campaign-name" name="name" autocomplete="off" required placeholder="Alpha Campaign"></div><div class="field"><label for="campaign-start">${t("label.startsAt")}</label><input id="campaign-start" name="starts_at" autocomplete="off" placeholder="2026-09-10T00:00:00Z"></div><div class="field"><label for="campaign-end">${t("label.endsAt")}</label><input id="campaign-end" name="ends_at" autocomplete="off" placeholder="2026-10-10T00:00:00Z"></div><button class="primary" type="submit" ${formDisabled ? "disabled" : ""}>${t("action.createCampaign")}</button></form>${rows ? `<div class="table-wrap"><table class="table dense-table"><thead><tr><th>${t("label.id")}</th><th>${t("label.code")}</th><th>${t("label.name")}</th><th>${t("label.status")}</th><th>${t("label.window")}</th><th>${t("label.created")}</th></tr></thead><tbody>${rows}</tbody></table></div>` : `<div class="state">${t("copy.noPartnerCampaigns")}</div>`}</div>`,
    );
  }
  function brokerAttributionPanel() {
    return panel(
      t("panel.partnerAttribution"),
      "advanced-side",
      `<div class="panel-body"><form id="broker-attribution-form" class="form-grid"><div class="field"><label for="attribution-code">${t("label.campaignCode")}</label><input id="attribution-code" name="campaign_code" autocomplete="off" required placeholder="alpha-campaign"></div><div class="field"><label for="attribution-label">${t("label.userReference")}</label><input id="attribution-label" name="user_reference" autocomplete="off" maxlength="120" placeholder="desk-visible-label"></div><button class="primary" type="submit" ${state.actionState !== "idle" ? "disabled" : ""}>${t("action.attributeAccount")}</button></form><p class="microcopy">${t("copy.attribution")}</p></div>`,
    );
  }
  function brokerReportPanel() {
    const tradeRows = state.brokerTrades
      .map((row) => {
        const view = brokerTradeReportView(row);
        return `<tr><td>${escapeHtml(view.time)}</td><td>${view.tradeId}</td><td>${escapeHtml(view.campaign)}</td><td>${escapeHtml(view.market)}</td><td>${escapeHtml(sideLabel(view.side))}</td><td>${escapeHtml(roleLabel(view.accountType))}</td><td>${html(roleLabel(view.origin))}</td><td>${escapeHtml(view.venueCode)}</td><td>${escapeHtml(view.liquidityBand)}</td><td>${escapeHtml(view.routingLabel)}</td><td>${escapeHtml(view.feeTier)}</td><td>${escapeHtml(view.bookingMarker)}</td><td>${escapeHtml(view.quantity)}</td><td>${escapeHtml(view.executionPrice)}</td><td>${escapeHtml(view.notional)}</td><td>${escapeHtml(view.fee)}</td><td>${escapeHtml(view.rebate)}</td></tr>`;
      })
      .join("");
    const monthlyRows = state.brokerMonthly
      .map((row) => {
        const view = brokerMonthlyReportView(row);
        return `<tr><td>${escapeHtml(view.bucket)}</td><td>${escapeHtml(view.campaign)}</td><td>${escapeHtml(view.tradeCount)}</td><td>${escapeHtml(view.notional)}</td><td>${escapeHtml(view.fee)}</td><td>${escapeHtml(view.rebate)}</td></tr>`;
      })
      .join("");
    const forbidden = state.brokerForbidden
      ? `<div class="state error"><strong>${t("copy.partnerReportsForbiddenTitle")}</strong><span>${t("copy.partnerReportsForbiddenBody")}</span></div>`
      : "";
    return panel(
      t("panel.partnerReport"),
      "advanced-wide",
      `<div class="panel-body panel-stack"><form id="broker-report-form" class="inline-form"><div class="field"><label for="broker-month">${t("label.month")}</label><input id="broker-month" name="month" placeholder="2026-09"></div><div class="field"><label for="broker-campaign-id">${t("label.campaign")} ID</label><input id="broker-campaign-id" name="campaign_id" inputmode="numeric" placeholder="optional"></div><button class="secondary" type="submit">${t("action.reloadReports")}</button></form>${forbidden}${monthlyRows ? `<div class="table-wrap"><table class="table"><thead><tr><th>${t("label.month")}</th><th>${t("label.campaign")}</th><th>${t("label.trades")}</th><th>${t("label.notional")}</th><th>${t("label.fee")}</th><th>${t("label.rebate")}</th></tr></thead><tbody>${monthlyRows}</tbody></table></div>` : `<div class="state compact-state">${t("copy.noMonthlyRows")}</div>`}${tradeRows ? `<div class="table-wrap"><table class="table dense-table"><thead><tr><th>${t("label.time")}</th><th>${t("label.trade")}</th><th>${t("label.campaign")}</th><th>${t("label.market")}</th><th>${t("label.side")}</th><th>${t("label.accountType")}</th><th>${t("label.origin")}</th><th>${t("label.venue")}</th><th>${t("label.band")}</th><th>${t("label.routing")}</th><th>${t("label.feeTier")}</th><th>${t("label.bookingMarker")}</th><th>${t("label.quantity")}</th><th>${t("label.price")}</th><th>${t("label.notional")}</th><th>${t("label.fee")}</th><th>${t("label.rebate")}</th></tr></thead><tbody>${tradeRows}</tbody></table></div>` : `<div class="state compact-state">${t("copy.noPartnerTradeRows")}</div>`}</div>`,
    );
  }
  function conditionalCreatePanel() {
    return panel(
      t("panel.conditionalCreate"),
      "advanced-side",
      `<div class="panel-body panel-stack"><div class="notice">${t("copy.conditionalNotice")}</div><form id="conditional-form" class="form-grid"><div class="field"><label for="conditional-market">${t("label.market")}</label><select id="conditional-market" name="market_symbol">${marketOptions()}</select></div><div class="field"><label for="conditional-side">${t("label.side")}</label><select id="conditional-side" name="side"><option value="buy">${sideLabel("buy")}</option><option value="sell">${sideLabel("sell")}</option></select></div><div class="field"><label for="trigger-type">${t("label.trigger")}</label><select id="trigger-type" name="trigger_type"><option value="last_trade_price_at_or_above">${triggerTypeLabel("last_trade_price_at_or_above")}</option><option value="last_trade_price_at_or_below">${triggerTypeLabel("last_trade_price_at_or_below")}</option></select></div><div class="field"><label for="trigger-price">${t("label.triggerPrice")}</label><input id="trigger-price" name="trigger_price" inputmode="decimal" required placeholder="100.00"></div><div class="field"><label for="conditional-limit-price">${t("label.limitPrice")}</label><input id="conditional-limit-price" name="limit_price" inputmode="decimal" required placeholder="100.00"></div><div class="field"><label for="conditional-quantity">${t("label.quantity")}</label><input id="conditional-quantity" name="quantity" inputmode="decimal" required placeholder="2.0000"></div><div class="field"><label for="conditional-client-id">${t("label.clientOrderId")}</label><input id="conditional-client-id" name="client_order_id" maxlength="64" autocomplete="off"></div><div class="field"><label for="conditional-expires">${t("label.expiry")}</label><input id="conditional-expires" name="expires_at" autocomplete="off" placeholder="2026-09-10T12:00:00Z"></div><button class="primary" type="submit" ${state.actionState !== "idle" ? "disabled" : ""}>${t("action.createInstruction")}</button></form></div>`,
    );
  }
  function conditionalListPanel() {
    if (state.advancedErrors.conditional && !state.conditionalOrders.length)
      return panel(
        t("panel.conditionalList"),
        "advanced-wide",
        retryState(
          "Условные заявки недоступны.",
          state.advancedErrors.conditional,
          "reload-conditional",
          t("action.retry"),
        ),
      );
    const rows = state.conditionalOrders
      .map((order) => {
        const view = conditionalOrderView(order);
        return `<tr><td>${view.id}</td><td>${escapeHtml(view.market)}</td><td><span class="side-tag ${view.side === "buy" ? "bid" : "ask"}">${escapeHtml(sideLabel(view.side))}</span></td><td>${escapeHtml(view.trigger)}</td><td>${escapeHtml(view.triggerPrice)}</td><td>${escapeHtml(view.limitPrice)}</td><td>${escapeHtml(view.quantity)}</td><td>${escapeHtml(statusLabel(view.status))}</td><td>${escapeHtml(view.expiresAt)}</td><td><button class="secondary" data-conditional-detail="${view.id}">${t("action.detail")}</button></td></tr>`;
      })
      .join("");
    return panel(
      t("panel.conditionalList"),
      "advanced-wide",
      rows
        ? `<div class="table-wrap"><table class="table dense-table"><thead><tr><th>${t("label.id")}</th><th>${t("label.market")}</th><th>${t("label.side")}</th><th>${t("label.trigger")}</th><th>${t("label.triggerPrice")}</th><th>${t("label.limit")}</th><th>${t("label.quantity")}</th><th>${t("label.status")}</th><th>${t("label.expiry")}</th><th>${t("label.action")}</th></tr></thead><tbody>${rows}</tbody></table></div>`
        : `<div class="state">${t("copy.noConditionalOrders")}</div>`,
    );
  }
  function conditionalDetailPanel() {
    if (!state.selectedConditional)
      return panel(
        t("panel.conditionalDetail"),
        "advanced-side",
        `<div class="state">${t("copy.selectConditional")}</div>`,
      );
    const view = conditionalOrderView(state.selectedConditional);
    return panel(
      t("panel.conditionalDetail"),
      "advanced-side",
      `<div class="panel-body"><dl class="review-grid"><dt>${t("label.id")}</dt><dd>${view.id}</dd><dt>${t("label.market")}</dt><dd>${escapeHtml(view.market)}</dd><dt>${t("label.side")}</dt><dd><span class="side-tag ${view.side === "buy" ? "bid" : "ask"}">${escapeHtml(sideLabel(view.side))}</span></dd><dt>${t("label.trigger")}</dt><dd>${escapeHtml(view.trigger)}</dd><dt>${t("label.triggerPrice")}</dt><dd>${escapeHtml(view.triggerPrice)}</dd><dt>${t("label.limitPrice")}</dt><dd>${escapeHtml(view.limitPrice)}</dd><dt>${t("label.quantity")}</dt><dd>${escapeHtml(view.quantity)}</dd><dt>${t("label.status")}</dt><dd>${escapeHtml(statusLabel(view.status))}</dd><dt>${t("label.clientOrderId")}</dt><dd class="clip-cell">${escapeHtml(view.clientOrderId)}</dd><dt>${t("label.triggeredAt")}</dt><dd>${escapeHtml(view.triggeredAt)}</dd><dt>${t("label.expiry")}</dt><dd>${escapeHtml(view.expiresAt)}</dd><dt>${t("label.created")}</dt><dd>${escapeHtml(view.createdAt)}</dd></dl><p class="microcopy">${t("copy.conditionalLifecycle")}</p></div>`,
    );
  }
  function feedControlPanel() {
    const cursor = feedCursor(state.feedEvents);
    const status = publicFeedStatusLabel({
      loading: state.feedState === "loading" && state.feedEvents.length === 0,
      stale: state.feedStale,
      cursor,
    });
    return panel(
      t("panel.feedControl"),
      "advanced-side",
      `<div class="panel-body panel-stack"><form id="feed-filter-form" class="form-grid"><div class="field"><label for="feed-market">${t("label.feedFilter")}</label><select id="feed-market" name="market_symbol"><option value="">${t("label.allMarkets")}</option>${state.markets.map((market) => `<option value="${escapeHtml(market.symbol)}" ${state.feedFilter === market.symbol ? "selected" : ""}>${escapeHtml(market.symbol)}</option>`).join("")}</select></div><button class="primary" type="submit">${t("action.applyFilter")}</button></form><div class="metric-row two-up"><div class="metric"><span class="label">${t("label.status")}</span><strong>${escapeHtml(status)}</strong></div><div class="metric"><span class="label">${t("label.events")}</span><strong>${state.feedEvents.length}</strong></div></div><button class="secondary" data-action="reload-feed">${t("action.pollNow")}</button><p class="microcopy">${t("copy.feedNotice")}</p></div>`,
    );
  }
  function feedEventsPanel() {
    if (state.feedState === "loading" && !state.feedEvents.length)
      return panel(
        t("panel.feedEvents"),
        "advanced-wide",
        `<div class="state">${t("state.loading")}...</div>`,
      );
    if (state.advancedErrors.feed && !state.feedEvents.length)
      return panel(
        t("panel.feedEvents"),
        "advanced-wide",
        retryState(
          "Публичная лента недоступна.",
          state.advancedErrors.feed,
          "reload-feed",
          t("action.retry"),
        ),
      );
    const rows = state.feedEvents
      .slice(-80)
      .reverse()
      .map((event) => {
        const view = publicFeedEventView(event);
        return `<tr><td>${view.sequence}</td><td>${escapeHtml(view.time)}</td><td>${escapeHtml(view.type)}</td><td>${escapeHtml(view.market)}</td><td>${escapeHtml(view.price)}</td><td>${escapeHtml(view.quantity)}</td><td>${html(view.reason)}</td></tr>`;
      })
      .join("");
    return panel(
      t("panel.feedEvents"),
      "advanced-wide",
      rows
        ? `<div class="table-wrap"><table class="table dense-table"><thead><tr><th>${t("label.sequence")}</th><th>${t("label.time")}</th><th>${t("label.type")}</th><th>${t("label.market")}</th><th>${t("label.price")}</th><th>${t("label.quantity")}</th><th>${t("label.reason")}</th></tr></thead><tbody>${rows}</tbody></table></div>`
        : `<div class="state">${t("copy.noFeedEvents")}</div>`,
    );
  }
  function marketOptions() {
    if (!state.markets.length)
      return `<option>${escapeHtml(state.symbol)}</option>`;
    return state.markets
      .map(
        (market) =>
          `<option value="${escapeHtml(market.symbol)}" ${market.symbol === state.symbol ? "selected" : ""}>${escapeHtml(market.symbol)}</option>`,
      )
      .join("");
  }
  function orderBookPanel() {
    if (state.publicState === "loading" && !state.book)
      return panel(
        t("panel.orderBook"),
        "book",
        `<div class="state">${t("state.loading")}...</div>`,
      );
    if (state.publicErrors.book && !state.book)
      return panel(
        t("panel.orderBook"),
        "book",
        retryState(
          "Книга заявок недоступна.",
          state.publicErrors.book,
          "reload-public",
          t("action.retry"),
        ),
      );
    if (!state.book)
      return panel(
        t("panel.orderBook"),
        "book",
        `<div class="state">${t("copy.noOrderBook")}</div>`,
      );
    const asks = state.book.asks.slice(0, 9).reverse();
    const bids = state.book.bids.slice(0, 9);
    const askRows = asks
      .map((level) => bookRow("ask", level.price, level.quantity))
      .join("");
    const bidRows = bids
      .map((level) => bookRow("bid", level.price, level.quantity))
      .join("");
    const spread =
      state.ticker?.best_bid && state.ticker?.best_ask
        ? `${compactDecimal(state.ticker.best_ask)} - ${compactDecimal(state.ticker.best_bid)}`
        : t("state.noTwoSidedMarket");
    const body =
      askRows || bidRows
        ? `<div class="table-wrap"><table class="table book-table"><thead><tr><th>${t("label.side")}</th><th>${t("label.price")}</th><th>${t("label.quantity")}</th></tr></thead><tbody>${askRows}<tr class="spread-row"><td colspan="3">${escapeHtml(spread)}</td></tr>${bidRows}</tbody></table></div>`
        : `<div class="state">${t("copy.noOpenLiquidity")}</div>`;
    return panel(t("panel.orderBook"), "book", body);
  }
  function bookRow(side, price, quantity) {
    const label = side === "bid" ? "Бид +" : "Аск -";
    return `<tr><td><span class="side-tag ${side}">${label}</span></td><td class="${side}">${escapeHtml(compactDecimal(price))}</td><td>${escapeHtml(compactDecimal(quantity))}</td></tr>`;
  }
  function marketContextPanel() {
    const ticker = state.ticker;
    const body = `
    <div class="panel-body market-context">
      <div class="metric-row">
        <div class="metric"><span class="label">${t("label.last")}</span><strong>${compactDecimal(ticker?.last_price)}</strong></div>
        <div class="metric"><span class="label">${t("label.bestBid")}</span><strong class="bid">${compactDecimal(ticker?.best_bid)}</strong></div>
        <div class="metric"><span class="label">${t("label.bestAsk")}</span><strong class="ask">${compactDecimal(ticker?.best_ask)}</strong></div>
        <div class="metric"><span class="label">${t("label.trades")}</span><strong>${ticker?.trade_count ?? "0"}</strong></div>
      </div>
      ${candleChart()}
    </div>
  `;
    return panel(
      t("panel.marketContext"),
      "context",
      state.publicErrors.ticker && !ticker
        ? retryState(
            "Тикер недоступен.",
            state.publicErrors.ticker,
            "reload-public",
            t("action.retry"),
          )
        : body,
    );
  }
  function candleChart() {
    if (state.publicErrors.candles && !state.candles.length)
      return `<div class="chart-empty warning">${t("copy.candlesUnavailable")}</div>`;
    if (!state.candles.length)
      return `<div class="chart-empty">${t("copy.noCandles")}</div>`;
    const points = state.candles
      .map((candle, index) => ({
        x: index,
        y: Number.parseFloat(candle.close),
      }))
      .filter((point) => Number.isFinite(point.y));
    if (points.length < 2) {
      const only = state.candles[state.candles.length - 1];
      return `<div class="chart-empty">${t("copy.oneCandle", { close: compactDecimal(only?.close), volume: compactDecimal(only?.volume) })}</div>`;
    }
    const min = Math.min(...points.map((point) => point.y));
    const max = Math.max(...points.map((point) => point.y));
    const span = max - min || 1;
    const width = 640;
    const height = 180;
    const path = points
      .map((point, index) => {
        const x = (point.x / Math.max(points.length - 1, 1)) * width;
        const y = height - ((point.y - min) / span) * (height - 16) - 8;
        return `${index === 0 ? "M" : "L"} ${x.toFixed(1)} ${y.toFixed(1)}`;
      })
      .join(" ");
    const first = state.candles[0];
    const last = state.candles[state.candles.length - 1];
    const summary = t("copy.candleSummary", {
      count: state.candles.length,
      interval: last?.interval ?? "1m",
      first: compactDecimal(first?.close),
      last: compactDecimal(last?.close),
    });
    return `
    <figure class="chart" aria-label="${escapeHtml(summary)}">
      <svg viewBox="0 0 ${width} ${height}" role="img" aria-labelledby="chart-title chart-desc" preserveAspectRatio="none">
        <title id="chart-title">${t("panel.marketContext")}</title>
        <desc id="chart-desc">${escapeHtml(summary)}</desc>
        <path class="chart-grid" d="M 0 45 H ${width} M 0 90 H ${width} M 0 135 H ${width}" />
        <path class="chart-line" d="${path}" />
      </svg>
      <figcaption>${escapeHtml(summary)}</figcaption>
    </figure>
  `;
  }
  function orderTicketPanel() {
    const market = selectedMarket();
    const authHint = state.session
      ? ""
      : `<p class="notice">${t("copy.signInOrder")}</p>`;
    const disabled = !state.session || state.actionState !== "idle";
    const errors = state.validationErrors.length
      ? `<div class="error-summary" role="alert">${state.validationErrors.map(escapeHtml).join(" ")}</div>`
      : "";
    return panel(
      t("panel.orderTicket"),
      "ticket",
      `
    <div class="panel-body">
      ${authHint}${errors}
      <div class="side-toggle" role="group" aria-label="${t("label.orderSide")}">
        <button type="button" class="${state.orderSide === "buy" ? "selected buy" : ""}" data-side="buy" aria-pressed="${state.orderSide === "buy"}">${sideLabel("buy")}</button>
        <button type="button" class="${state.orderSide === "sell" ? "selected sell" : ""}" data-side="sell" aria-pressed="${state.orderSide === "sell"}">${sideLabel("sell")}</button>
      </div>
      <form id="order-form" class="form-grid">
        <div class="field"><label for="limit-price">${t("label.limitPrice")} (${escapeHtml(market?.quote_asset ?? "quote")})</label><input id="limit-price" name="limit_price" inputmode="decimal" autocomplete="off" required placeholder="100.0"></div>
        <div class="field"><label for="quantity">${t("label.quantity")} (${escapeHtml(market?.base_asset ?? "base")})</label><input id="quantity" name="quantity" inputmode="decimal" autocomplete="off" required placeholder="1"></div>
        <div class="field"><label for="client-order-id">${t("label.clientOrderId")}</label><input id="client-order-id" name="client_order_id" maxlength="64" autocomplete="off" placeholder="desk-001"></div>
        <button class="primary" type="submit" ${disabled ? "disabled" : ""}>${state.actionState === "submitting" ? t("action.submitting") : `${t("action.reviewOrder")} · ${sideLabel(state.orderSide)}`}</button>
      </form>
      <p class="microcopy">${t("copy.orderTicket")}</p>
    </div>
  `,
    );
  }
  function tradesPanel() {
    if (state.publicErrors.trades && !state.trades.length)
      return panel(
        t("panel.publicTrades"),
        "trades",
        retryState(
          "Публичные сделки недоступны.",
          state.publicErrors.trades,
          "reload-public",
          t("action.retry"),
        ),
      );
    const rows = state.trades
      .slice(0, 12)
      .map(
        (trade) =>
          `<tr><td>${escapeHtml(formatUtcTime(trade.created_at))}</td><td>${escapeHtml(compactDecimal(trade.price))}</td><td>${escapeHtml(compactDecimal(trade.quantity))}</td><td>${escapeHtml(roleLabel(String(trade.aggressor_side ?? "n/a")))}</td></tr>`,
      )
      .join("");
    return panel(
      t("panel.publicTrades"),
      "trades",
      rows
        ? `<div class="table-wrap"><table class="table"><thead><tr><th>${t("label.time")}</th><th>${t("label.price")}</th><th>${t("label.quantity")}</th><th>${t("label.side")}</th></tr></thead><tbody>${rows}</tbody></table></div>`
        : `<div class="state">${t("copy.noPublicTrades")}</div>`,
    );
  }
  function ordersPanel() {
    if (!state.session)
      return panel(
        t("panel.openOrders"),
        "orders",
        `<div class="state">${t("copy.signInOrders")}</div>`,
      );
    if (state.ordersState === "loading")
      return panel(
        t("panel.openOrders"),
        "orders",
        `<div class="state">${t("state.loading")}...</div>`,
      );
    if (state.ordersState === "error")
      return panel(
        t("panel.openOrders"),
        "orders",
        retryState(
          "Заявки недоступны.",
          "Сессия или сеть не позволили загрузить список заявок.",
          "reload-orders",
          t("action.retry"),
        ),
      );
    const rows = state.orders
      .slice(0, 14)
      .map((order) => orderRow(order, false))
      .join("");
    return panel(
      t("panel.openOrders"),
      "orders",
      rows
        ? `<div class="table-wrap"><table class="table"><thead><tr><th>${t("label.side")}</th><th>${t("label.market")}</th><th>${t("label.limit")}</th><th>${t("label.remaining")} / ${t("label.original")}</th><th>${t("label.status")}</th><th>${t("label.action")}</th></tr></thead><tbody>${rows}</tbody></table></div>`
        : `<div class="state">${t("copy.noOrders")}</div>`,
    );
  }
  function walletsPanel() {
    if (state.accountState === "loading" && !state.wallets.length)
      return panel(
        t("panel.wallets"),
        "balances",
        `<div class="state">${t("state.loading")}...</div>`,
      );
    if (state.accountErrors.wallets && !state.wallets.length)
      return panel(
        t("panel.wallets"),
        "balances",
        retryState(
          "Балансы недоступны.",
          state.accountErrors.wallets,
          "reload-account",
          t("action.retry"),
        ),
      );
    const rows = state.wallets
      .map((wallet) => {
        const view = walletView(wallet);
        return `<tr><td><span class="symbol">${escapeHtml(view.asset)}</span></td><td>${escapeHtml(view.available)}</td><td>${escapeHtml(view.locked)}</td><td>${escapeHtml(view.total)}</td><td>${escapeHtml(view.updatedAt)}</td></tr>`;
      })
      .join("");
    const button = `<button class="primary" data-action="claim-faucet" ${state.actionState !== "idle" ? "disabled" : ""}>${state.actionState === "funding" ? t("action.funding") : t("action.fundDemo")}</button>`;
    const notice = state.faucetNotice
      ? `<p class="notice">${escapeHtml(state.faucetNotice)}</p>`
      : `<p class="microcopy">${t("copy.faucetNotice")}</p>`;
    return panel(
      t("panel.wallets"),
      "balances",
      `<div class="panel-body panel-stack"><div class="panel-actions">${button}</div>${notice}${rows ? `<div class="table-wrap"><table class="table"><thead><tr><th>${t("label.asset")}</th><th>${t("label.available")}</th><th>${t("label.locked")}</th><th>${t("label.total")}</th><th>${t("label.updated")}</th></tr></thead><tbody>${rows}</tbody></table></div>` : `<div class="state">${t("copy.noWallets")}</div>`}</div>`,
    );
  }
  function ledgerPanel() {
    if (state.accountState === "loading" && !state.ledgerEntries.length)
      return panel(
        t("panel.ledger"),
        "ledger",
        `<div class="state">${t("state.loading")}...</div>`,
      );
    if (state.accountErrors.ledger && !state.ledgerEntries.length)
      return panel(
        t("panel.ledger"),
        "ledger",
        retryState(
          "Журнал недоступен.",
          state.accountErrors.ledger,
          "reload-account",
          t("action.retry"),
        ),
      );
    const rows = state.ledgerEntries
      .slice(0, 40)
      .map((entry) => {
        const view = ledgerEntryView(entry);
        return `<tr><td>${escapeHtml(view.time)}</td><td><span class="symbol">${escapeHtml(view.asset)}</span></td><td>${escapeHtml(view.bucket)}</td><td class="${view.direction === "debit" ? "ask" : view.direction === "credit" ? "bid" : ""}">${escapeHtml(view.amount)}</td><td>${escapeHtml(view.type)}</td><td>${escapeHtml(view.source)}</td></tr>`;
      })
      .join("");
    return panel(
      t("panel.ledger"),
      "ledger",
      rows
        ? `<div class="table-wrap"><table class="table"><thead><tr><th>${t("label.time")}</th><th>${t("label.asset")}</th><th>${t("label.bucket")}</th><th>${t("label.amount")}</th><th>${t("label.type")}</th><th>${t("label.source")}</th></tr></thead><tbody>${rows}</tbody></table></div>`
        : `<div class="state">${t("copy.noLedger")}</div>`,
    );
  }
  function orderHistoryPanel() {
    if (state.ordersState === "loading" && !state.orders.length)
      return panel(
        t("panel.orderHistory"),
        "order-history",
        `<div class="state">${t("state.loading")}...</div>`,
      );
    if (state.ordersState === "error")
      return panel(
        t("panel.orderHistory"),
        "order-history",
        retryState(
          "История заявок недоступна.",
          "Сессия или сеть не позволили загрузить заявки.",
          "reload-orders",
          t("action.retry"),
        ),
      );
    const rows = state.orders.map((order) => orderRow(order, true)).join("");
    return panel(
      t("panel.orderHistory"),
      "order-history",
      rows
        ? `<div class="table-wrap"><table class="table dense-table"><thead><tr><th>${t("label.side")}</th><th>${t("label.market")}</th><th>${t("label.limit")}</th><th>${t("label.original")}</th><th>${t("label.filled")}</th><th>${t("label.remaining")}</th><th>${t("label.status")}</th><th>${t("label.clientOrderId")}</th><th>${t("label.created")}</th><th>${t("label.action")}</th></tr></thead><tbody>${rows}</tbody></table></div>`
        : `<div class="state">${t("copy.noOrderLifecycle")}</div>`,
    );
  }
  function orderRow(order, full) {
    const action = isOrderCancellable(order)
      ? `<button class="secondary danger" data-cancel-order="${order.id}" ${state.actionState !== "idle" ? "disabled" : ""}>${t("action.cancelOrder")}</button>`
      : "-";
    if (!full) {
      return `<tr><td><span class="side-tag ${order.side === "buy" ? "bid" : "ask"}">${escapeHtml(sideLabel(order.side))}</span></td><td>${escapeHtml(order.market_symbol)}</td><td>${escapeHtml(compactDecimal(order.limit_price))}</td><td>${escapeHtml(compactDecimal(order.remaining_quantity))} / ${escapeHtml(compactDecimal(order.original_quantity))}</td><td>${escapeHtml(statusLabel(order.status))}</td><td>${action}</td></tr>`;
    }
    return `<tr><td><span class="side-tag ${order.side === "buy" ? "bid" : "ask"}">${escapeHtml(sideLabel(order.side))}</span></td><td>${escapeHtml(order.market_symbol)}</td><td>${escapeHtml(compactDecimal(order.limit_price))}</td><td>${escapeHtml(compactDecimal(order.original_quantity))}</td><td>${escapeHtml(compactDecimal(order.filled_quantity))}</td><td>${escapeHtml(compactDecimal(order.remaining_quantity))}</td><td>${escapeHtml(statusLabel(order.status))}</td><td class="clip-cell">${escapeHtml(order.client_order_id ?? "-")}</td><td>${escapeHtml(formatUtcTime(order.created_at))}</td><td>${action}</td></tr>`;
  }
  function userTradesPanel() {
    if (state.accountState === "loading" && !state.userTrades.length)
      return panel(
        t("panel.executionsReceipts"),
        "executions",
        `<div class="state">${t("state.loading")}...</div>`,
      );
    if (state.accountErrors.userTrades && !state.userTrades.length)
      return panel(
        t("panel.executionsReceipts"),
        "executions",
        retryState(
          "Исполнения недоступны.",
          state.accountErrors.userTrades,
          "reload-account",
          t("action.retry"),
        ),
      );
    const rows = state.userTrades
      .map((trade) => {
        const view = ownerTradeSummaryView(trade);
        return `<tr><td>${escapeHtml(view.time)}</td><td>${escapeHtml(String(view.tradeId))}</td><td>${escapeHtml(view.market)}</td><td><span class="side-tag ${view.side === "buy" ? "bid" : "ask"}">${escapeHtml(sideLabel(view.side))}</span></td><td>${escapeHtml(view.accountType)}</td><td>${escapeHtml(view.price)}</td><td>${escapeHtml(view.quantity)}</td><td>${escapeHtml(view.quoteAmount)}</td><td class="clip-cell">${escapeHtml(view.clientOrderId)}</td><td>${escapeHtml(view.settlementStatus)}</td><td><button class="secondary" data-trade-detail="${view.tradeId}">${t("action.executionPacket")}</button> <button class="secondary" data-trade-receipt="${view.tradeId}">${t("action.receipt")}</button></td></tr>`;
      })
      .join("");
    return panel(
      t("panel.executionsReceipts"),
      "executions",
      rows
        ? `<div class="table-wrap"><table class="table dense-table"><thead><tr><th>${t("label.time")}</th><th>${t("label.trade")}</th><th>${t("label.market")}</th><th>${t("label.side")}</th><th>${t("label.accountType")}</th><th>${t("label.price")}</th><th>${t("label.quantity")}</th><th>${t("label.quote")}</th><th>${t("label.clientOrderId")}</th><th>${t("label.settlement")}</th><th>${t("label.action")}</th></tr></thead><tbody>${rows}</tbody></table></div>`
        : `<div class="state">${t("copy.noExecutions")}</div>`,
    );
  }
  function panel(title, area, body) {
    return `<section class="panel ${area}"><div class="panel-head"><h2 class="panel-title">${title}</h2></div>${body}</section>`;
  }
  function retryState(title, detail, action, label) {
    return `<div class="state error"><strong>${escapeHtml(title)}</strong><span>${escapeHtml(detail)}</span><button class="secondary" data-action="${escapeHtml(action)}">${escapeHtml(label)}</button></div>`;
  }
  function applyTableLabels(root) {
    root.querySelectorAll("table").forEach((table) => {
      const headers = Array.from(table.querySelectorAll("thead th")).map(
        (header) => header.textContent?.trim() ?? "",
      );
      table.querySelectorAll("tbody tr").forEach((row) => {
        Array.from(row.children).forEach((cell, index) => {
          if (cell instanceof HTMLElement && headers[index])
            cell.dataset.label = headers[index];
        });
      });
    });
  }
  function messageDialog() {
    return `<div class="dialog-backdrop" role="presentation"><div class="dialog" role="alertdialog" aria-modal="true"><h2>VoltaX</h2><p>${escapeHtml(state.message)}</p><div class="dialog-actions"><button class="primary" data-action="dismiss-message">${t("action.close")}</button></div></div></div>`;
  }
  function orderReviewDialog(input) {
    const review = buildOrderReview(input, selectedMarket());
    return `<div class="dialog-backdrop" role="presentation"><div class="dialog review-dialog" role="dialog" aria-modal="true" aria-labelledby="review-title">
    <h2 id="review-title">${t("dialog.reviewOrder")}</h2>${reviewRows(review)}
    <p class="notice">${t("copy.orderReviewNotice")}</p>
    <div class="dialog-actions"><button class="secondary" data-action="cancel-review">${t("action.edit")}</button><button class="primary" data-action="confirm-order" ${state.actionState !== "idle" ? "disabled" : ""}>${state.actionState === "submitting" ? t("action.submitting") : t("action.submitOrder")}</button></div>
  </div></div>`;
  }
  function reviewRows(review) {
    const notional = review.estimated_notional
      ? `${compactDecimal(review.estimated_notional)} ${review.quote_asset}`
      : t("value.unableToEstimate");
    return `<dl class="review-grid">
    <dt>${t("label.side")}</dt><dd><span class="side-tag ${review.side === "buy" ? "bid" : "ask"}">${escapeHtml(sideLabel(review.side))}</span></dd>
    <dt>${t("label.market")}</dt><dd>${escapeHtml(review.market_symbol)}</dd>
    <dt>${t("label.type")}</dt><dd>${t("value.limit")}</dd>
    <dt>${t("label.limitPrice")}</dt><dd>${escapeHtml(compactDecimal(review.limit_price))} ${escapeHtml(review.quote_asset)}</dd>
    <dt>${t("label.quantity")}</dt><dd>${escapeHtml(compactDecimal(review.quantity))} ${escapeHtml(review.base_asset)}</dd>
    <dt>${t("label.estimatedNotional")}</dt><dd>${escapeHtml(notional)}</dd>
    <dt>${t("label.clientOrderId")}</dt><dd>${escapeHtml(review.client_order_id ?? t("value.notProvided"))}</dd>
  </dl>`;
  }
  function cancelReviewDialog(order) {
    return `<div class="dialog-backdrop" role="presentation"><div class="dialog review-dialog" role="dialog" aria-modal="true" aria-labelledby="cancel-title">
    <h2 id="cancel-title">${t("dialog.cancelOrder")}</h2>
    <dl class="review-grid">
      <dt>${t("label.side")}</dt><dd><span class="side-tag ${order.side === "buy" ? "bid" : "ask"}">${escapeHtml(sideLabel(order.side))}</span></dd>
      <dt>${t("label.market")}</dt><dd>${escapeHtml(order.market_symbol)}</dd>
      <dt>${t("label.limitPrice")}</dt><dd>${escapeHtml(compactDecimal(order.limit_price))}</dd>
      <dt>${t("label.originalFilledRemaining")}</dt><dd>${escapeHtml(compactDecimal(order.original_quantity))} / ${escapeHtml(compactDecimal(order.filled_quantity))} / ${escapeHtml(compactDecimal(order.remaining_quantity))}</dd>
      <dt>${t("label.status")}</dt><dd>${escapeHtml(statusLabel(order.status))}</dd>
    </dl>
    <p class="notice">${t("copy.cancelNotice")}</p>
    <div class="dialog-actions"><button class="secondary" data-action="dismiss-cancel">${t("action.keepOrder")}</button><button class="primary danger-fill" data-action="confirm-cancel" ${state.actionState !== "idle" ? "disabled" : ""}>${state.actionState === "cancelling" ? t("action.cancelling") : t("action.cancelOrder")}</button></div>
  </div></div>`;
  }
  function detailDialog() {
    const dialog = state.detailDialog;
    if (!dialog) return "";
    let body = `<div class="state">${t("dialog.loadingDetail", { title: dialog.title })}</div>`;
    if (dialog.state === "error")
      body = `<div class="state error"><strong>${escapeHtml(dialog.message ?? t("dialog.detailUnavailable"))}</strong></div>`;
    if (dialog.state === "ready" && dialog.publicTrade)
      body = publicTradeRows(dialog.publicTrade);
    if (dialog.state === "ready" && dialog.tradeDetail)
      body = tradeDetailRows(dialog.tradeDetail);
    if (dialog.state === "ready" && dialog.receipt)
      body = receiptRows(dialog.receipt);
    return `<div class="dialog-backdrop" role="presentation"><div class="dialog detail-dialog" role="dialog" aria-modal="true" aria-labelledby="detail-title"><h2 id="detail-title">${escapeHtml(dialog.title)}</h2>${body}<div class="dialog-actions"><button class="primary" data-action="close-detail">${t("action.close")}</button></div></div></div>`;
  }
  function publicTradeRows(view) {
    return `<dl class="review-grid">
    <dt>${t("label.trade")}</dt><dd>${escapeHtml(view.tradeId ?? "-")}</dd>
    <dt>${t("label.market")}</dt><dd>${escapeHtml(view.market)}</dd>
    <dt>${t("label.price")}</dt><dd>${escapeHtml(view.price)}</dd>
    <dt>${t("label.quantity")}</dt><dd>${escapeHtml(view.quantity)}</dd>
    <dt>${t("label.quoteAmount")}</dt><dd>${escapeHtml(view.quoteAmount)}</dd>
    <dt>${t("label.aggressorSide")}</dt><dd>${escapeHtml(view.aggressorSide)}</dd>
    <dt>${t("label.time")}</dt><dd>${escapeHtml(view.time)}</dd>
  </dl>`;
  }
  function tradeDetailRows(view) {
    const account = view.accountBooking;
    const venue = view.venueAllocation;
    return `<dl class="review-grid">
    <dt>${t("label.trade")}</dt><dd>${escapeHtml(view.tradeId ?? "-")}</dd>
    <dt>${t("label.market")}</dt><dd>${escapeHtml(view.market)}</dd>
    <dt>${t("label.price")}</dt><dd>${escapeHtml(view.price)}</dd>
    <dt>${t("label.quantity")}</dt><dd>${escapeHtml(view.quantity)}</dd>
    <dt>${t("label.quoteAmount")}</dt><dd>${escapeHtml(view.quoteAmount)}</dd>
    <dt>${t("label.aggressorSide")}</dt><dd>${escapeHtml(view.aggressorSide)}</dd>
    <dt>${t("label.bookingSide")}</dt><dd>${account ? `<span class="side-tag ${account.side === "buy" ? "bid" : "ask"}">${escapeHtml(sideLabel(account.side))}</span>` : "-"}</dd>
    <dt>${t("label.bookingRef")}</dt><dd>${escapeHtml(account?.bookingRef ?? "-")}</dd>
    <dt>${t("label.deskSide")}</dt><dd>${venue ? `<span class="side-tag ${venue.side === "buy" ? "bid" : "ask"}">${escapeHtml(sideLabel(venue.side))}</span>` : "-"}</dd>
    <dt>${t("label.venueRef")}</dt><dd>${escapeHtml(venue?.deskRef ?? "-")}</dd>
    <dt>${t("label.status")}</dt><dd>${escapeHtml(account?.settlementStatus ?? venue?.settlementStatus ?? "-")}</dd>
    <dt>${t("label.time")}</dt><dd>${escapeHtml(view.time)}</dd>
  </dl>`;
  }
  function receiptRows(view) {
    return `<dl class="review-grid">
    <dt>${t("label.trade")}</dt><dd>${escapeHtml(view.tradeId)}</dd>
    <dt>${t("label.side")}</dt><dd><span class="side-tag ${view.side === "buy" ? "bid" : "ask"}">${escapeHtml(sideLabel(view.side))}</span></dd>
    <dt>${t("label.accountType")}</dt><dd>${escapeHtml(view.accountType)}</dd>
    <dt>${t("label.market")}</dt><dd>${escapeHtml(view.market)}</dd>
    <dt>${t("label.clientOrderId")}</dt><dd>${escapeHtml(view.clientOrderId)}</dd>
    <dt>${t("label.price")}</dt><dd>${escapeHtml(view.price)}</dd>
    <dt>${t("label.quantity")}</dt><dd>${escapeHtml(view.quantity)}</dd>
    <dt>${t("label.quoteAmount")}</dt><dd>${escapeHtml(view.quoteAmount)}</dd>
    <dt>${t("label.debit")}</dt><dd>${escapeHtml(view.debit)}</dd>
    <dt>${t("label.credit")}</dt><dd>${escapeHtml(view.credit)}</dd>
    <dt>${t("label.fee")}</dt><dd>${escapeHtml(view.fee)}</dd>
    <dt>${t("label.settlement")}</dt><dd>${escapeHtml(view.settlementStatus)}</dd>
    <dt>${t("label.time")}</dt><dd>${escapeHtml(view.time)}</dd>
  </dl>`;
  }
  function bindEvents() {
    document
      .querySelectorAll("[data-view]")
      .forEach((button) =>
        button.addEventListener("click", () =>
          switchView(viewFromDataset(button.dataset.view)),
        ),
      );
    document
      .querySelectorAll("[data-action='open-auth']")
      .forEach((element) => element.addEventListener("click", openAuth));
    document
      .querySelector("[data-action='logout']")
      ?.addEventListener("click", () => logout());
    document
      .querySelector("[data-action='dismiss-message']")
      ?.addEventListener("click", () => {
        state.message = null;
        render();
      });
    document
      .querySelector("[data-action='reload-public']")
      ?.addEventListener("click", () => void loadPublic());
    document
      .querySelector("[data-action='reload-orders']")
      ?.addEventListener("click", () => void loadOrders());
    document
      .querySelector("[data-action='reload-account']")
      ?.addEventListener("click", () => void loadAccount());
    document
      .querySelector("[data-action='reload-rfq']")
      ?.addEventListener("click", () => void loadRfq());
    document
      .querySelector("[data-action='reload-conditional']")
      ?.addEventListener("click", () => void loadConditional());
    document
      .querySelector("[data-action='reload-feed']")
      ?.addEventListener("click", () => void loadFeed(false));
    document
      .querySelector("[data-action='claim-faucet']")
      ?.addEventListener("click", () => void claimFaucet());
    document
      .querySelector("[data-action='cancel-review']")
      ?.addEventListener("click", () => {
        state.reviewOrder = null;
        render();
      });
    document
      .querySelector("[data-action='confirm-order']")
      ?.addEventListener("click", () => void confirmOrder());
    document
      .querySelector("[data-action='dismiss-cancel']")
      ?.addEventListener("click", () => {
        state.cancelOrder = null;
        render();
      });
    document
      .querySelector("[data-action='confirm-cancel']")
      ?.addEventListener("click", () => void confirmCancel());
    document
      .querySelector("[data-action='close-detail']")
      ?.addEventListener("click", () => {
        state.detailDialog = null;
        render();
      });
    document
      .querySelector("#market-select")
      ?.addEventListener("change", (event) => {
        state.symbol = event.currentTarget.value;
        state.ticker = null;
        state.candles = [];
        state.book = null;
        state.trades = [];
        state.acknowledgement = null;
        void loadPublic();
      });
    document.querySelectorAll("[data-side]").forEach((button) =>
      button.addEventListener("click", () => {
        state.orderSide = button.dataset.side === "sell" ? "sell" : "buy";
        state.validationErrors = [];
        render();
      }),
    );
    document
      .querySelector("#order-form")
      ?.addEventListener("submit", submitOrderReview);
    document.querySelector("#rfq-form")?.addEventListener("submit", submitRfq);
    document
      .querySelector("#rfq-quote-form")
      ?.addEventListener("submit", submitRfqQuote);
    document
      .querySelector("#broker-campaign-form")
      ?.addEventListener("submit", submitPartnerCampaign);
    document
      .querySelector("#broker-attribution-form")
      ?.addEventListener("submit", submitPartnerAttribution);
    document
      .querySelector("#broker-report-form")
      ?.addEventListener("submit", submitPartnerReportFilter);
    document
      .querySelector("#conditional-form")
      ?.addEventListener("submit", submitConditionalOrder);
    document
      .querySelector("#feed-filter-form")
      ?.addEventListener("submit", submitFeedFilter);
    document.querySelectorAll("[data-cancel-order]").forEach((button) =>
      button.addEventListener("click", () => {
        const id = Number(button.dataset.cancelOrder);
        state.cancelOrder =
          state.orders.find((order) => order.id === id) ?? null;
        render();
      }),
    );
    document
      .querySelectorAll("[data-trade-detail]")
      .forEach((button) =>
        button.addEventListener(
          "click",
          () => void openTradeDetailPacket(Number(button.dataset.tradeDetail)),
        ),
      );
    document
      .querySelectorAll("[data-trade-receipt]")
      .forEach((button) =>
        button.addEventListener(
          "click",
          () => void openTradeReceipt(Number(button.dataset.tradeReceipt)),
        ),
      );
    document
      .querySelectorAll("[data-rfq-detail]")
      .forEach((button) =>
        button.addEventListener(
          "click",
          () => void openRfqDetail(Number(button.dataset.rfqDetail)),
        ),
      );
    document
      .querySelectorAll("[data-rfq-workup]")
      .forEach((button) =>
        button.addEventListener(
          "click",
          () => void openRfqWorkup(Number(button.dataset.rfqWorkup)),
        ),
      );
    document
      .querySelectorAll("[data-rfq-accept]")
      .forEach((button) =>
        button.addEventListener(
          "click",
          () => void acceptRfqQuote(Number(button.dataset.rfqAccept)),
        ),
      );
    document
      .querySelectorAll("[data-conditional-detail]")
      .forEach((button) =>
        button.addEventListener(
          "click",
          () =>
            void openConditionalDetail(
              Number(button.dataset.conditionalDetail),
            ),
        ),
      );
  }
  function switchView(view) {
    state.activeView = view;
    state.message = null;
    state.detailDialog = null;
    if (view !== "feed") stopFeedPolling();
    if (view !== "automation") stopConditionalPolling();
    render();
    if (view === "portfolio") void Promise.all([loadOrders(), loadAccount()]);
    if (view === "rfq") void loadRfq();
    if (view === "broker") void loadPartner();
    if (view === "automation") {
      void loadConditional();
      startConditionalPolling();
    }
    if (view === "feed") {
      void Promise.all([
        state.markets.length ? Promise.resolve() : loadPublic(),
        loadFeed(state.feedEvents.length === 0),
      ]);
      startFeedPolling();
    }
  }
  function viewFromDataset(view) {
    if (
      view === "portfolio" ||
      view === "rfq" ||
      view === "broker" ||
      view === "automation" ||
      view === "feed"
    )
      return view;
    return "trade";
  }
  function startFeedPolling() {
    if (feedTimer !== null) return;
    feedTimer = window.setInterval(() => {
      if (state.activeView === "feed") void loadFeed(false);
    }, 10000);
  }
  function stopFeedPolling() {
    if (feedTimer === null) return;
    window.clearInterval(feedTimer);
    feedTimer = null;
  }
  function startConditionalPolling() {
    if (!state.session) return;
    conditionalPoller.start(() => {
      if (state.activeView === "automation" && state.session)
        void loadConditional(true);
    });
  }
  function stopConditionalPolling() {
    conditionalPoller.stop();
  }
  function openAuth() {
    if (state.session) return;
    const existing = document.querySelector("#auth-form");
    if (existing) {
      existing.querySelector("input")?.focus();
      return;
    }
    state.message = null;
    const backdrop = document.createElement("div");
    backdrop.className = "dialog-backdrop";
    backdrop.innerHTML = `<div class="dialog" role="dialog" aria-modal="true" aria-labelledby="auth-title"><h2 id="auth-title">${t("auth.title")}</h2><p class="muted">${t("auth.subtitle")}</p><form id="auth-form" class="form-grid"><div class="field"><label for="auth-mode">${t("auth.mode")}</label><select id="auth-mode" name="mode"><option value="login">${t("auth.login")}</option><option value="register">${t("auth.register")}</option></select></div><div class="field"><label for="username">${t("auth.username")}</label><input id="username" name="username" required autocomplete="username"></div><div class="field"><label for="password">${t("auth.password")}</label><input id="password" name="password" required type="password" minlength="12" autocomplete="current-password"></div><div class="field" id="account-type-field" hidden><label for="account-type">${t("auth.accountType")}</label><select id="account-type" name="account_profile"><option value="spot">${accountTypeLabel("spot")}</option><option value="liquidity">${accountTypeLabel("liquidity")}</option><option value="partner">${accountTypeLabel("partner")}</option></select></div><div class="dialog-actions"><button type="button" class="secondary" data-close-auth>${t("action.cancel")}</button><button class="primary" type="submit">${t("action.continue")}</button></div></form></div>`;
    document.body.append(backdrop);
    const mode = backdrop.querySelector("#auth-mode");
    mode?.addEventListener("change", () => {
      const accountTypeField = backdrop.querySelector("#account-type-field");
      if (accountTypeField && mode)
        accountTypeField.hidden = mode.value !== "register";
    });
    backdrop
      .querySelector("[data-close-auth]")
      ?.addEventListener("click", () => backdrop.remove());
    backdrop
      .querySelector("#auth-form")
      ?.addEventListener("submit", async (event) => {
        event.preventDefault();
        const form = new FormData(event.currentTarget);
        const username = String(form.get("username") ?? "");
        const password = String(form.get("password") ?? "");
        try {
          const response =
            form.get("mode") === "register"
              ? await api.register(
                  username,
                  password,
                  String(form.get("account_profile") ?? "spot"),
                )
              : await api.login(username, password);
          const token = response.session.token;
          if (!token) throw new ApiError(0, "request_failed");
          state.session = { token, user: response.user };
          saveSession(state.session);
          state.acknowledgement = t("auth.signedIn", {
            username: response.user.username,
          });
          backdrop.remove();
          await loadActiveAuthenticatedData();
        } catch (error) {
          backdrop.remove();
          state.message = errorMessage(error);
          render();
        }
      });
    backdrop.querySelector("#username")?.focus();
  }
  async function loadActiveAuthenticatedData() {
    const jobs = [loadOrders()];
    if (state.activeView === "trade") jobs.push(loadPublic());
    if (state.activeView === "portfolio") jobs.push(loadAccount());
    if (state.activeView === "rfq") jobs.push(loadRfq());
    if (state.activeView === "broker") jobs.push(loadPartner());
    if (state.activeView === "automation") jobs.push(loadConditional());
    await Promise.all(jobs);
    if (state.activeView === "automation") startConditionalPolling();
  }
  function submitOrderReview(event) {
    event.preventDefault();
    if (!state.session) return;
    const form = new FormData(event.currentTarget);
    const clientId = String(form.get("client_order_id") ?? "").trim();
    const input = {
      market_symbol: state.symbol,
      side: state.orderSide,
      order_type: "limit",
      limit_price: String(form.get("limit_price") ?? "").trim(),
      quantity: String(form.get("quantity") ?? "").trim(),
      ...(clientId ? { client_order_id: clientId } : {}),
    };
    const errors = validateOrder(input);
    state.validationErrors = errors;
    if (errors.length) {
      render();
      return;
    }
    state.reviewOrder = input;
    state.acknowledgement = null;
    render();
  }
  async function confirmOrder() {
    if (!state.reviewOrder) return;
    const input = state.reviewOrder;
    state.actionState = "submitting";
    render();
    try {
      const response = await api.createOrder(input);
      state.reviewOrder = null;
      state.validationErrors = [];
      state.acknowledgement = t("msg.orderAccepted", {
        side: sideLabel(response.order.side),
        quantity: compactDecimal(response.order.original_quantity),
        market: response.order.market_symbol,
        price: compactDecimal(response.order.limit_price),
      });
      await Promise.all([loadOrders(), loadPublic(), loadAccount()]);
    } catch (error) {
      state.reviewOrder = null;
      if (!handleSessionError(error)) state.message = errorMessage(error);
      render();
    } finally {
      state.actionState = "idle";
      render();
    }
  }
  async function confirmCancel() {
    if (!state.cancelOrder) return;
    const order = state.cancelOrder;
    state.actionState = "cancelling";
    render();
    try {
      await api.cancelOrder(order.id);
      state.cancelOrder = null;
      state.acknowledgement = t("msg.orderCancelAccepted", {
        market: order.market_symbol,
      });
      await Promise.all([loadOrders(), loadPublic(), loadAccount()]);
    } catch (error) {
      if (!handleSessionError(error)) state.message = errorMessage(error);
      render();
    } finally {
      state.actionState = "idle";
      render();
    }
  }
  async function claimFaucet() {
    if (!state.session) return;
    state.actionState = "funding";
    state.faucetNotice = null;
    render();
    try {
      const key =
        state.faucetKey ??
        `ui:${Date.now()}:${Math.random().toString(36).slice(2, 10)}`;
      state.faucetKey = key;
      const response = await api.faucet(key);
      if (response.wallets) state.wallets = response.wallets;
      if (response.ledger_entries?.length)
        state.ledgerEntries = [
          ...response.ledger_entries,
          ...state.ledgerEntries,
        ];
      state.faucetNotice = faucetMessage(response.faucet);
      await loadAccount();
    } catch (error) {
      if (!handleSessionError(error)) state.faucetNotice = errorMessage(error);
    } finally {
      state.actionState = "idle";
      render();
    }
  }
  async function openTradeDetailPacket(id) {
    state.detailDialog = {
      title: t("dialog.executionPacket"),
      state: "loading",
      kind: "trade-detail",
    };
    render();
    try {
      const response = await api.tradeDetail(id);
      state.detailDialog = {
        title: t("dialog.executionPacket"),
        state: "ready",
        kind: "trade-detail",
        tradeDetail: participantTradeDetailView(response.trade),
      };
    } catch (error) {
      if (handleSessionError(error)) return;
      state.detailDialog = {
        title: t("dialog.executionPacket"),
        state: "error",
        kind: "trade-detail",
        message: errorMessage(error),
      };
    }
    render();
  }
  async function openTradeReceipt(id) {
    state.detailDialog = {
      title: t("dialog.ownerReceipt"),
      state: "loading",
      kind: "receipt",
    };
    render();
    try {
      const response = await api.tradeReceipt(id);
      state.detailDialog = {
        title: t("dialog.ownerReceipt"),
        state: "ready",
        kind: "receipt",
        receipt: ownerReceiptView(response.receipt),
      };
    } catch (error) {
      if (handleSessionError(error)) return;
      state.detailDialog = {
        title: t("dialog.ownerReceipt"),
        state: "error",
        kind: "receipt",
        message: errorMessage(error),
      };
    }
    render();
  }
  async function submitRfq(event) {
    event.preventDefault();
    if (!state.session) return;
    const form = new FormData(event.currentTarget);
    const validated = validateRfqCreateForm({
      market_symbol: String(form.get("market_symbol") ?? state.symbol),
      side: String(form.get("side") ?? "buy"),
      quantity: String(form.get("quantity") ?? ""),
      target_price: String(form.get("target_price") ?? ""),
      delivery_terms: String(form.get("delivery_terms") ?? ""),
      public_comment: String(form.get("public_comment") ?? ""),
      expires_at: String(form.get("expires_at") ?? ""),
    });
    if (!validated.ok) {
      state.message = validated.errors.join(" ");
      render();
      return;
    }
    const input = validated.input;
    state.actionState = "submitting";
    state.rfqDetailNotice = null;
    render();
    try {
      const response = await api.createRfq(input);
      locallyOwnedRfqIds.add(response.rfq.id);
      state.selectedRfq = response.rfq;
      state.workup = null;
      state.acknowledgement = t("msg.rfqOpened", {
        id: response.rfq.id,
        market: response.rfq.market_symbol,
      });
      await loadRfq();
    } catch (error) {
      if (!handleSessionError(error)) state.message = errorMessage(error);
    } finally {
      state.actionState = "idle";
      render();
    }
  }
  async function openRfqDetail(id) {
    if (!locallyOwnedRfqIds.has(id)) {
      state.selectedRfq = null;
      state.workup = null;
      state.rfqDetailNotice = t("copy.ownerDetailSession");
      render();
      return;
    }
    state.rfqDetailNotice = null;
    try {
      state.selectedRfq = (await api.rfqDetail(id)).rfq;
      state.workup = null;
    } catch (error) {
      if (!handleSessionError(error)) {
        state.selectedRfq = null;
        state.workup = null;
        state.rfqDetailNotice = rfqOwnerDetailUnavailableMessage(
          error instanceof ApiError ? error.status : null,
        );
      }
    }
    render();
  }
  async function openRfqWorkup(id) {
    state.rfqDetailNotice = null;
    try {
      state.workup = (await api.rfqWorkup(id)).rfq;
      state.selectedRfq = null;
    } catch (error) {
      if (!handleSessionError(error)) state.message = errorMessage(error);
    }
    render();
  }
  async function submitRfqQuote(event) {
    event.preventDefault();
    if (!state.session) return;
    const formElement = event.currentTarget;
    const form = new FormData(formElement);
    const price = String(form.get("price") ?? "").trim();
    const quantity = String(form.get("quantity") ?? "").trim();
    const errors = validateDecimalInstruction({ price, quantity });
    if (errors.length) {
      state.message = errors.join(" ");
      render();
      return;
    }
    const expiresAt = String(form.get("expires_at") ?? "").trim();
    const input = {
      price,
      quantity,
      ...(expiresAt ? { expires_at: expiresAt } : {}),
    };
    state.actionState = "submitting";
    state.rfqDetailNotice = null;
    render();
    try {
      const rfqId = Number(formElement.dataset.rfqId);
      const response = await api.submitRfqQuote(rfqId, input);
      state.acknowledgement = t("msg.quoteSubmitted", {
        quoteId: response.quote.id,
        rfqId,
      });
      await openRfqWorkup(rfqId);
      await loadRfq();
    } catch (error) {
      if (!handleSessionError(error)) state.message = errorMessage(error);
    } finally {
      state.actionState = "idle";
      render();
    }
  }
  async function acceptRfqQuote(quoteId) {
    if (!state.selectedRfq) return;
    const rfqId = state.selectedRfq.id;
    state.actionState = "submitting";
    state.rfqDetailNotice = null;
    render();
    try {
      const response = await api.acceptRfqQuote(rfqId, quoteId);
      state.selectedRfq = response.rfq;
      state.acknowledgement = t("msg.rfqAccepted", { rfqId, quoteId });
      await Promise.all([loadRfq(), loadPublic(), loadAccount()]);
    } catch (error) {
      if (!handleSessionError(error)) state.message = errorMessage(error);
    } finally {
      state.actionState = "idle";
      render();
    }
  }
  async function submitPartnerCampaign(event) {
    event.preventDefault();
    if (!state.session) return;
    const form = new FormData(event.currentTarget);
    const startsAt = String(form.get("starts_at") ?? "").trim();
    const endsAt = String(form.get("ends_at") ?? "").trim();
    state.actionState = "submitting";
    render();
    try {
      const response = await api.createPartnerCampaign({
        campaign_code: String(form.get("campaign_code") ?? "").trim(),
        name: String(form.get("name") ?? "").trim(),
        starts_at: startsAt || null,
        ends_at: endsAt || null,
      });
      state.acknowledgement = t("msg.campaignCreated", {
        code: response.campaign.campaign_code,
      });
      await loadPartner();
    } catch (error) {
      if (!handleSessionError(error)) state.message = errorMessage(error);
    } finally {
      state.actionState = "idle";
      render();
    }
  }
  async function submitPartnerAttribution(event) {
    event.preventDefault();
    if (!state.session) return;
    const form = new FormData(event.currentTarget);
    const userRef = String(form.get("user_reference") ?? "").trim();
    state.actionState = "submitting";
    render();
    try {
      const response = await api.createPartnerAttribution({
        campaign_code: String(form.get("campaign_code") ?? "").trim(),
        ...(userRef ? { user_reference: userRef } : {}),
      });
      state.acknowledgement = t("msg.accountAttributed", {
        code: response.attribution.campaign_code,
      });
    } catch (error) {
      if (!handleSessionError(error)) state.message = errorMessage(error);
    } finally {
      state.actionState = "idle";
      render();
    }
  }
  function submitPartnerReportFilter(event) {
    event.preventDefault();
    const form = new FormData(event.currentTarget);
    const params = {};
    const month = String(form.get("month") ?? "").trim();
    const campaignId = String(form.get("campaign_id") ?? "").trim();
    if (month) params.month = month;
    if (campaignId) params.campaign_id = campaignId;
    void loadPartner(params);
  }
  async function submitConditionalOrder(event) {
    event.preventDefault();
    if (!state.session) return;
    const form = new FormData(event.currentTarget);
    const triggerPrice = String(form.get("trigger_price") ?? "").trim();
    const limitPrice = String(form.get("limit_price") ?? "").trim();
    const quantity = String(form.get("quantity") ?? "").trim();
    const errors = [
      ...validateDecimalInstruction({ price: triggerPrice, quantity }),
      ...validateDecimalInstruction({ price: limitPrice }),
    ];
    if (errors.length) {
      state.message = Array.from(new Set(errors)).join(" ");
      render();
      return;
    }
    const clientId = String(form.get("client_order_id") ?? "").trim();
    const expiresAt = String(form.get("expires_at") ?? "").trim();
    const input = {
      market_symbol: String(form.get("market_symbol") ?? state.symbol),
      side: String(form.get("side") ?? "buy") === "sell" ? "sell" : "buy",
      trigger_type:
        String(form.get("trigger_type")) === "last_trade_price_at_or_below"
          ? "last_trade_price_at_or_below"
          : "last_trade_price_at_or_above",
      trigger_price: triggerPrice,
      limit_price: limitPrice,
      quantity,
      ...(clientId ? { client_order_id: clientId } : {}),
      ...(expiresAt ? { expires_at: expiresAt } : {}),
    };
    state.actionState = "submitting";
    render();
    try {
      const response = await api.createConditionalOrder(input);
      state.selectedConditional = response.conditional_order;
      state.acknowledgement = t("msg.conditionalCreated", {
        id: response.conditional_order.id,
      });
      await loadConditional();
    } catch (error) {
      if (!handleSessionError(error)) state.message = errorMessage(error);
    } finally {
      state.actionState = "idle";
      render();
    }
  }
  async function openConditionalDetail(id) {
    try {
      state.selectedConditional = (
        await api.conditionalOrder(id)
      ).conditional_order;
    } catch (error) {
      if (!handleSessionError(error)) state.message = errorMessage(error);
    }
    render();
  }
  function submitFeedFilter(event) {
    event.preventDefault();
    const form = new FormData(event.currentTarget);
    state.feedFilter = String(form.get("market_symbol") ?? "");
    void loadFeed(true);
  }
  render();
  void (async () => {
    await restoreSession();
    await Promise.all([loadPublic(), loadOrders()]);
  })();
})();
