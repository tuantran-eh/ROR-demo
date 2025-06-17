class PostPolicy < ApplicationPolicy
  def show?
    admin_or(-> { user.present? })
  end

  def create?
    admin_or(-> { user.present? })
  end

  def update?
    admin_or(-> { user.present? && user.id == record.created_by_id })
  end

  def destroy?
    admin_or(-> { user.present? && user.id == record.created_by_id })
  end

  class Scope < Scope
    def resolve
      if user&.admin?
        scope.all
      else
        scope.all # Adjust for non-admins if needed
      end
    end
  end

  private
  def admin_or(rule)
    user&.admin? || rule.call
  end
end
