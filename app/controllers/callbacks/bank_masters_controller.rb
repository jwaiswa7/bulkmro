class Callbacks::BankMastersController < Callbacks::BaseController
  protect_from_forgery with: :null_session
  before_action :authenticate_callback

  def create
    resp_status = 0
    resp_msg = 'Invalid request.'
    resp_response = ''
    #request params: {"BPBankAccounts":[{"BPCode":"SC-8645","SupBankName":"CENTRALBANKOFINDIA","SupBankBranch":"","SupBankAddress":"","SupBankCountryCode":"IN","SupBankCode":"CBIN","SupBankAccountNO":"3219501464","SupBankBeneficiaryMobile":"","SupBankBeneficiaryEmail":"","SupBankAccountName":"SuriSportsIndustriesPvtLtd","SupBankSwiftCode":"","SupBankABA":"","SupBankIBAN":"","SupBankIfsc":"","SupBankCurrency":"INR","InternalKey":"14"}]}
    # Db table: banks_code
    # BankCode=SupBankCode, BankName=SupBankName, CountryCode=SupBankCountryCode, AbsoluteEntry=AbsoluteEntry
    if params['BankCode'] && params['BankName'] && params['CountryCode']
      if params['AbsoluteEntry']
        #update bank details against AbsoluteEntry
        resp_status = 1
        resp_msg = "Bank Master updated successfully"
      else
        #Insert bank details
        resp_status = 1
        resp_msg = "Bank Master created successfully"
      end
    end
    response = format_response(resp_status, resp_msg, resp_response)
    render json: response, status: :ok
  end
end