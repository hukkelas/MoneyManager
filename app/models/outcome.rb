class Outcome < ApplicationRecord
  belongs_to :account
  belongs_to :category
  belongs_to :user
  validates :account      , presence: true
  validates :category     , presence: true
  validates :user         , presence: true
  validates :transfer_date, presence: true

  def add_transfer
    self.set_processed(false)
    self.delay(run_at: self.transfer_date).do_transfer(self.amount,self.transfer_date)
  end

  def set_processed(value)
    self.processed = value
    self.save
  end

  def do_transfer(amount,transfer_date)
    if self.amount == amount && self.transfer_date.to_s == transfer_date.to_s
      if self.processed
        a = Account.new
        a.name = 'FEIL FEIL FEIL.' + self.id.to_s + self.transfer_date.to_s + self.amount.to_s
        a.balance = 0
        a.save
      end
      self.set_processed(true)
      self.account.withdraw(amount)
    end
  end


  def revert_transaction
    if processed
      self.account.deposit(self.amount)
    end
  end
end