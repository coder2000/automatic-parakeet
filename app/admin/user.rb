ActiveAdmin.register User do
  permit_params :email, :username, :given_name, :surname, :locale, :phone_number, :staff

  index do
    selectable_column
    id_column
    column :email
    column :username
    column :given_name
    column :surname
    column :locale
    column :sign_in_count
    column :created_at
    column :staff
    actions
  end

  filter :email
  filter :username
  filter :given_name
  filter :surname
  filter :locale
  filter :staff
  filter :created_at

  form do |f|
    f.inputs do
      f.input :email
      f.input :username
      f.input :given_name
      f.input :surname
      f.input :locale
      f.input :phone_number
      f.input :staff
    end
    f.actions
  end
end

