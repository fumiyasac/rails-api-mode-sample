class Item < ApplicationRecord
  # 画像アップロード時に切り出すファイルのサイズを指定する
  has_attached_file :picture, styles: { large: "640x480>", medium: "300x300>", thumb: "100x100>" }
  # 画像のバリデーションを設定する（画像は必須 & 画像のMIME-TYPEが正しい形式であること）
  validates_attachment :picture, presence: true, content_type: { content_type: ["image/jpeg", "image/gif", "image/png"] }
  do_not_validate_attachment_file_type :picture
end
