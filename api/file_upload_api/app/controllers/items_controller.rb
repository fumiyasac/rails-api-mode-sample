class ItemsController < ApplicationController
  before_action :set_item, only: [:show, :update, :destroy]

  # GET /items
  # GET /items.json
  def index
    @items = Item.all
    # index.json.jbuilderで出力するjsonを整形する（出力するJSONの形式を変えています）
  end

  # GET /items/1
  # GET /items/1.json
  def show
    # show.json.jbuilderで出力するjsonを整形する（今回は省略）
  end

  # POST /items
  def create
    @item = Item.new(item_params)

    if @item.save
      # 今回はコールバックをフロント側で受け取るのでステータスを返すだけのものにする
      render json: @item, status: :created, location: @item
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  # ※ここから先のupdate/destoryアクションは使用しない
  # PATCH/PUT /items/1
  def update
    if @item.update(item_params)
      render json: @item, status: :ok, location: @item
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  # DELETE /items/1
  def destroy
    @item.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = Item.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def item_params
      params.require(:item).permit(:title, :description, :picture)
    end
end
