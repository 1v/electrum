class CreateWallets < ActiveRecord::Migration[6.1]
  def change
    create_table :wallets do |t|
      t.string :master_public_key
      t.bigint :balance_confirmed
      t.bigint :balance_unconfirmed

      t.timestamps
    end
  end
end
