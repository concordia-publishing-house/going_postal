require 'going_postal'
ActiveRecord::Base.extend(GoingPostal::MakeAddress)
