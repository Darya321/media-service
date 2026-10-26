class AllowNullInquiryExtras < ActiveRecord::Migration[8.1]
  def change
    change_column_null :inquiries, :extras, true
  end
end
