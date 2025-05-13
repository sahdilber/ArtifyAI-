# app.py
from flask import Flask, request, jsonify
from flask_cors import CORS
import tensorflow as tf
import tensorflow_hub as hub
import numpy as np
from PIL import Image
import io
import base64

app = Flask(__name__)
CORS(app)

def load_image_from_bytes(image_bytes, max_dim=512):
    img = Image.open(io.BytesIO(image_bytes)).convert('RGB')
    img = np.array(img).astype(np.float32) / 255.0
    img = tf.convert_to_tensor(img)
    shape = tf.cast(tf.shape(img)[:-1], tf.float32)
    scale = max_dim / tf.reduce_max(shape)
    new_shape = tf.cast(shape * scale, tf.int32)
    img = tf.image.resize(img, new_shape)
    return img[tf.newaxis, :]

def tensor_to_base64(tensor):
    tensor = tensor * 255
    tensor = tf.cast(tensor, tf.uint8)
    image = tf.squeeze(tensor, axis=0)
    pil_img = Image.fromarray(image.numpy())
    buf = io.BytesIO()
    pil_img.save(buf, format='JPEG')
    return base64.b64encode(buf.getvalue()).decode('utf-8')

print("✅ Model yükleniyor...")
hub_model = hub.load("https://tfhub.dev/google/magenta/arbitrary-image-stylization-v1-256/2")

@app.route('/stylize', methods=['POST'])
def stylize_image():
    if 'content_image' not in request.files or 'style_image' not in request.files:
        return jsonify({'error': 'İki görsel (content_image ve style_image) yükleyin.'}), 400

    content_bytes = request.files['content_image'].read()
    style_bytes = request.files['style_image'].read()

    try:
        content_image = load_image_from_bytes(content_bytes)
        style_image = load_image_from_bytes(style_bytes)

        stylized_image = hub_model(tf.constant(content_image), tf.constant(style_image))[0]
        result_base64 = tensor_to_base64(stylized_image)

        return jsonify({'stylized_image': result_base64})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5050)