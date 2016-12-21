class SessionsController < Devise::SessionsController
  def new
    super
  end

  def create
    @user = User.new(user_params)
    if (@user.ubs_no.length == 8 && !(@user.ubs_no.start_with? 'o')) || (@user.ubs_no.length == 9 && (@user.ubs_no.start_with? 'o'))
      @user.ubs_no = 'o' + @user.ubs_no unless @user.ubs_no.start_with? 'o'
      Ubs.login(@user)
      @user = User.find_by(ubs_no: @user.ubs_no)
      @user.present? && @user.is_ubs_active ? (sign_in_and_redirect @user, event: :authentication) : (redirect_to clubs_path, alert: 'Aktif öğrenci olmadığınız için sisteme giriş yapamazsınız')
    elsif @user.ubs_no.length == 11
      @db_user = User.find_by(idnumber: @user.ubs_no)
      if @db_user.present?
        bcrypt   = BCrypt::Password.new(@db_user.encrypted_password)
        password = BCrypt::Engine.hash_secret("#{@user.password}#{resource.class.pepper}", bcrypt.salt)
        @isactive = @db_user.admin? ? true : Ubs.active_academic_control(@user.ubs_no)
        bcrypt.to_s == password.to_s && @isactive ? (sign_in_and_redirect @db_user, event: :authentication) : (redirect_to clubs_path, alert: 'Girdiğiniz bilgiler hatalı ya da durumunuz aktif değil, Lütfen tekrar deneyin.')
      else
        redirect_to clubs_path, alert: 'Girdiğiniz bilgiler hatalı. Lütfen tekrar deneyin.'
      end
    else
      redirect_to clubs_path, alert: 'Girdiğiniz bilgiler hatalı. Lütfen tekrar deneyin.'
    end
  end

  def destroy
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    redirect_to clubs_path, alert: 'Başarılı çıkış yaptınız'
  end

  private

  def user_params
    params.require(:user).permit(:ubs_no, :idnumber, :password)
  end
end
