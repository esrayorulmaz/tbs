class ProfilesController < ApplicationController
  def show
    @profile = Profile.find_by(user_id: params[:id])
    @member_clubs = @profile.user.roles.map { |x| x.club_period.club unless x.club_period.blank?} unless @profile.user.roles.blank?
    authorize @profile
  end

  def update
    @profile = Profile.find(params[:id])
    @params = params.require(:profile).permit(:phone, :adress, :email, :id)
    @profile.phone = params[:profile][:phone]
    @profile.email = params[:profile][:email]
    @profile.adress = params[:profile][:adress]
    @profile.save ? flash[:success] = 'Profil başarıyla güncellenmiştir' : flash[:error] = 'Profil güncellenirken hata oluştu, yeniden deneyiniz'
    redirect_to :back
  end
end
