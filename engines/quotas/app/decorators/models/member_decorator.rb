Core::Member.class_eval do
  has_many :quotas, class_name: "Quotas::Quota", as: :subject

  # all Members belonging to the given user or a project owned by the given user
  def self.relevant_for_quotas(user)
    where(<<-SQL.squish, id: user.id)
      EXISTS
      (SELECT * FROM core_members my_membs
       WHERE core_members.project_id = my_membs.project_id
       AND my_membs.user_id = :id
       AND (core_members.user_id = :id
            OR my_membs.owner))
    SQL
  end

  def relevant_for_quotas?(user)
    user.id == self.user_id ||
      user.id ==
      self.class.find_by(owner: true, project_id: project_id).user_id
  end
end
