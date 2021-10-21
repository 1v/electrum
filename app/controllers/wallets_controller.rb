class WalletsController < ApplicationController
  def index
    @wallets = Wallet.all.order(created_at: :desc)
  end

  def create
    @wallet = Wallet.new(wallet_params)
    if @wallet.save
      flash[:notice] = 'Wallet added'
      redirect_to action: :index
    else
      flash[:error] = @wallet.errors.full_messages.join('<br>')
      redirect_to action: :index
    end
  end

  def destroy
    @wallet = Wallet.find(params[:id])
    @wallet.destroy
    flash[:notice] = 'Wallet removed'
    redirect_to action: :index
  end

  private

  def wallet_params
    params.require(:wallet).permit(:master_public_key)
  end
end
