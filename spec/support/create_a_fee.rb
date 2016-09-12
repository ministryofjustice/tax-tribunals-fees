def fee
  Fee.create(
    glimr_id: 1,
    case_reference: 'TT/2016/00001',
    case_title: 'You vs HMRC',
    description: 'Lodgement Fee',
    amount: 2000,
    govpay_payment_id: 'rmpaurrjuehgpvtqg997bt50f'
  )
end
