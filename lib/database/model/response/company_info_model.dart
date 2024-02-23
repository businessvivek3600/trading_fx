class CompanyInfoModel {
  String? companyId;
  String? companyName;
  String? email;
  String? address;
  String? mobile;
  String? website;
  String? businessPlan;
  String? chatDisabled;
  String? embedPopup;
  String? embedContent;
  String? popupImg;
  String? popupImage;
  String? username;
  String? isLogin;
  String? isSignup;
  String? isBuyPack;
  String? dpMinimumWithdraw;
  String? cMinimumWithdraw;
  String? drMinimumWithdraw;
  String? dpMinimumTransfer;
  String? cMinimumTransfer;
  String? dpTopupTPer;
  String? cTopupTPer;
  String? cBankAdminPer;
  String? cBtcAdminPer;
  String? cUsdtAdminPer;
  String? cTrxAdminPer;
  String? cEthAdminPer;
  String? uBankAdminPer;
  String? uBtcAdminPer;
  String? uUsdtAdminPer;
  String? uTrxAdminPer;
  String? uEthAdminPer;
  String? tradingDay;
  String? wdDailyProfit;
  String? wdCommission;
  String? wdDrCoin;
  String? trDailyProfit;
  String? trCommission;
  String? status;
  String? runCronClient;
  String? runCronSale;
  String? runCronTC;
  String? runCronPayout;
  String? usd1InCoin;
  String? usd1InBtc;
  String? usd1InUsdt;
  String? usd1InTrx;
  String? usd1InEth;
  String? coin1InUsd;
  String? tradePrice;
  String? accountInfo;
  String? qrCode;
  String? cancelBtn;
  String? tradeIncome;
  String? companyMessage;
  String? tradeAmt;
  String? popupUrl;

  CompanyInfoModel(
      {this.companyId,
      this.companyName,
      this.email,
      this.address,
      this.mobile,
      this.website,
      this.businessPlan,
      this.chatDisabled,
      this.embedPopup,
      this.embedContent,
      this.popupImg,
      this.popupImage,
      this.username,
      this.isLogin,
      this.isSignup,
      this.isBuyPack,
      this.dpMinimumWithdraw,
      this.cMinimumWithdraw,
      this.drMinimumWithdraw,
      this.dpMinimumTransfer,
      this.cMinimumTransfer,
      this.dpTopupTPer,
      this.cTopupTPer,
      this.cBankAdminPer,
      this.cBtcAdminPer,
      this.cUsdtAdminPer,
      this.cTrxAdminPer,
      this.cEthAdminPer,
      this.uBankAdminPer,
      this.uBtcAdminPer,
      this.uUsdtAdminPer,
      this.uTrxAdminPer,
      this.uEthAdminPer,
      this.tradingDay,
      this.wdDailyProfit,
      this.wdCommission,
      this.wdDrCoin,
      this.trDailyProfit,
      this.trCommission,
      this.status,
      this.runCronClient,
      this.runCronSale,
      this.runCronTC,
      this.runCronPayout,
      this.usd1InCoin,
      this.usd1InBtc,
      this.usd1InUsdt,
      this.usd1InTrx,
      this.usd1InEth,
      this.coin1InUsd,
      this.tradePrice,
      this.accountInfo,
      this.qrCode,
      this.cancelBtn,
      this.tradeIncome,
      this.companyMessage,
      this.tradeAmt,
      this.popupUrl});

  CompanyInfoModel.fromJson(Map<String, dynamic> json) {
    companyId = json['company_id'];
    companyName = json['company_name'];
    email = json['email'];
    address = json['address'];
    mobile = json['mobile'];
    website = json['website'];
    businessPlan = json['business_plan'];
    chatDisabled = json['chat_disabled'];
    embedPopup = json['embed_popup'];
    embedContent = json['embed_content'];
    popupImg = json['popup_img'];
    popupImage = json['popup_image'];
    username = json['username'];
    isLogin = json['is_login'];
    isSignup = json['is_signup'];
    isBuyPack = json['is_buy_pack'];
    dpMinimumWithdraw = json['dp_minimum_withdraw'];
    cMinimumWithdraw = json['c_minimum_withdraw'];
    drMinimumWithdraw = json['dr_minimum_withdraw'];
    dpMinimumTransfer = json['dp_minimum_transfer'];
    cMinimumTransfer = json['c_minimum_transfer'];
    dpTopupTPer = json['dp_topup_t_per'];
    cTopupTPer = json['c_topup_t_per'];
    cBankAdminPer = json['c_bank_admin_per'];
    cBtcAdminPer = json['c_btc_admin_per'];
    cUsdtAdminPer = json['c_usdt_admin_per'];
    cTrxAdminPer = json['c_trx_admin_per'];
    cEthAdminPer = json['c_eth_admin_per'];
    uBankAdminPer = json['u_bank_admin_per'];
    uBtcAdminPer = json['u_btc_admin_per'];
    uUsdtAdminPer = json['u_usdt_admin_per'];
    uTrxAdminPer = json['u_trx_admin_per'];
    uEthAdminPer = json['u_eth_admin_per'];
    tradingDay = json['trading_day'];
    wdDailyProfit = json['wd_daily_profit'];
    wdCommission = json['wd_commission'];
    wdDrCoin = json['wd_dr_coin'];
    trDailyProfit = json['tr_daily_profit'];
    trCommission = json['tr_commission'];
    status = json['status'];
    runCronClient = json['run_cron_client'];
    runCronSale = json['run_cron_sale'];
    runCronTC = json['run_cron_t_c'];
    runCronPayout = json['run_cron_payout'];
    usd1InCoin = json['usd_1_in_coin'];
    usd1InBtc = json['usd_1_in_btc'];
    usd1InUsdt = json['usd_1_in_usdt'];
    usd1InTrx = json['usd_1_in_trx'];
    usd1InEth = json['usd_1_in_eth'];
    coin1InUsd = json['coin_1_in_usd'];
    tradePrice = json['trade_price'];
    accountInfo = json['account_info'];
    qrCode = json['qr_code'];
    cancelBtn = json['cancel_btn'];
    tradeIncome = json['trade_income'];
    companyMessage = json['company_message'];
    tradeAmt = json['trade_amt'];
    popupUrl = json['popup_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['company_id'] = companyId;
    data['company_name'] = companyName;
    data['email'] = email;
    data['address'] = address;
    data['mobile'] = mobile;
    data['website'] = website;
    data['business_plan'] = businessPlan;
    data['chat_disabled'] = chatDisabled;
    data['embed_popup'] = embedPopup;
    data['embed_content'] = embedContent;
    data['popup_img'] = popupImg;
    data['popup_image'] = popupImage;
    data['username'] = username;
    data['is_login'] = isLogin;
    data['is_signup'] = isSignup;
    data['is_buy_pack'] = isBuyPack;
    data['dp_minimum_withdraw'] = dpMinimumWithdraw;
    data['c_minimum_withdraw'] = cMinimumWithdraw;
    data['dr_minimum_withdraw'] = drMinimumWithdraw;
    data['dp_minimum_transfer'] = dpMinimumTransfer;
    data['c_minimum_transfer'] = cMinimumTransfer;
    data['dp_topup_t_per'] = dpTopupTPer;
    data['c_topup_t_per'] = cTopupTPer;
    data['c_bank_admin_per'] = cBankAdminPer;
    data['c_btc_admin_per'] = cBtcAdminPer;
    data['c_usdt_admin_per'] = cUsdtAdminPer;
    data['c_trx_admin_per'] = cTrxAdminPer;
    data['c_eth_admin_per'] = cEthAdminPer;
    data['u_bank_admin_per'] = uBankAdminPer;
    data['u_btc_admin_per'] = uBtcAdminPer;
    data['u_usdt_admin_per'] = uUsdtAdminPer;
    data['u_trx_admin_per'] = uTrxAdminPer;
    data['u_eth_admin_per'] = uEthAdminPer;
    data['trading_day'] = tradingDay;
    data['wd_daily_profit'] = wdDailyProfit;
    data['wd_commission'] = wdCommission;
    data['wd_dr_coin'] = wdDrCoin;
    data['tr_daily_profit'] = trDailyProfit;
    data['tr_commission'] = trCommission;
    data['status'] = status;
    data['run_cron_client'] = runCronClient;
    data['run_cron_sale'] = runCronSale;
    data['run_cron_t_c'] = runCronTC;
    data['run_cron_payout'] = runCronPayout;
    data['usd_1_in_coin'] = usd1InCoin;
    data['usd_1_in_btc'] = usd1InBtc;
    data['usd_1_in_usdt'] = usd1InUsdt;
    data['usd_1_in_trx'] = usd1InTrx;
    data['usd_1_in_eth'] = usd1InEth;
    data['coin_1_in_usd'] = coin1InUsd;
    data['trade_price'] = tradePrice;
    data['account_info'] = accountInfo;
    data['qr_code'] = qrCode;
    data['cancel_btn'] = cancelBtn;
    data['trade_income'] = tradeIncome;
    data['company_message'] = companyMessage;
    data['trade_amt'] = tradeAmt;
    data['popup_url'] = popupUrl;
    return data;
  }
}
