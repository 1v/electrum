class Wallet < ApplicationRecord
  has_one_attached :file

  validates :master_public_key,
    presence: true,
    uniqueness: true

  validate :validate_key_with_client, on: :create

  def get_client
    Jimson::Client.new("http://#{ENV['ELECTRUM_USERNAME']}:#{ENV['ELECTRUM_PASSWORD']}@localhost:#{ENV['ELECTRUM_PORT']}")
  end

  def update_balance
    client = get_client
    wallet_path = ActiveStorage::Blob.service.send(:path_for, self.file.key)
    client.load_wallet(wallet_path: wallet_path)
    10.times do
      wallet_loaded = client.list_wallets.detect{ |w| w['path'] == wallet_path }
      sleep(0.5)
      if wallet_loaded['synchronized'] then break else next end
    end
    balances = client.getbalance(wallet: wallet_path)
    self.balance_confirmed = (balances['confirmed'].to_f * 100000000).to_i
    self.balance_unconfirmed = (balances['unconfirmed'].to_f * 100000000).to_i
    save
  end

  def self.update_balances
    all.find_each do |wallet|
      wallet.update_balance
    end
  end

  def validate_key_with_client
    client = get_client
    temp_file = "#{Rails.root.join('tmp')}/temp_wallet_#{SecureRandom.hex}"
    File.delete(temp_file) if File.file?(temp_file)
    begin
      client.restore(text: self.master_public_key, wallet_path: temp_file)
    rescue Jimson::Client::Error::ServerError
      errors.add(:master_public_key, :invalid)
    else
      self.file.attach(io: File.new(temp_file), filename: 'wallet')
    ensure
      File.delete(temp_file) if File.file?(temp_file)
    end
  end
end
