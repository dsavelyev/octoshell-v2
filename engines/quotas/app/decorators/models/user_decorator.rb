User.class_eval do
  # all Members belonging to this user or a project owned by this user
  def allowed_accounts_for_quotas
    joined = Core::Member.joins <<-SQL.squish
      INNER JOIN core_members my_membs
      ON core_members.project_id = my_membs.project_id
         AND (core_members.user_id = my_membs.user_id
              OR my_membs.owner)
    SQL

    joined.where('my_membs.user_id = ?', id)
  end

  def account_allowed_for_quotas?(member)
    not allowed_accounts_for_quotas.where(id: member.id).empty?
  end
end
