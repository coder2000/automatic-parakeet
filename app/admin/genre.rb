ActiveAdmin.register Genre do
  permit_params :name, :key

  index do
    selectable_column
    id_column
    column :name
    column :key
    column :created_at
    column :updated_at
    actions
  end

  filter :name
  filter :key
  filter :created_at

  form do |f|
    f.inputs do
      f.input :name
      f.input :key
    end
    f.actions
  end
end
