class Order < ApplicationRecord

    has_many :order_items

    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :email, presence: true
    validates :address_1, presence: true
    validates :city, presence: true
    validates :country, presence: true

    accepts_nested_attributes_for :order_items


    def add_from_cart(cart)

        cart.order_items.all.each do |item|
            self.order_items.new(product: item.product, quantity: item.quantity)
        end

    end

    def save_and_charge
        # check our data is valid
        # if it is, charge in stripe
        # if it isn't, return false
        # charge in stripe and save

        if self.valid?
    
            Stripe.api_key = "sk_test_51HsOXkLzZFXpG8fpjXfKZlXgOfF31nLWuz4rMobtavdVb3GHuHaPetXQmojb0fqyWBcfEr7lqxqtJkdndcggcOnL009sGmIdp8"

            Stripe::Charge.create(
                amount: self.total_price, 
                currency: "eur",
                source: self.stripe_token,
                description: "Order for " + self.email,
                statement_descriptor: "Another Pin Co")

            self.save

        else
            # doesn't pass validations
            false
        end

    end

    def total_price
        @total = 0

        order_items.each do |item|
            @total = @total + item.product.price * item.quantity
        end

        @total
    end

end
