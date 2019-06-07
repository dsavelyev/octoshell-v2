Core::Member.class_eval do
  has_many :quotas, class_name: "Quotas::Quota", as: :subject, dependent: :destroy

  # all Members belonging to the given user or a project owned by the given user
  scope :under_user, (lambda do |user_id|
    where(<<-SQL.squish, user_id: user_id)
      EXISTS (
        SELECT * FROM core_members my_membs
        WHERE core_members.project_id = my_membs.project_id
        AND my_membs.user_id = :user_id
        AND (core_members.user_id = :user_id
             OR my_membs.owner)
      )
    SQL
  end)

  def under_user?(user_id)
    user_id == self.user_id ||
      user_id ==
        self.class.where(owner: true, project_id: project_id)
            .select(:user_id)[0]
            .user_id
  end
end
