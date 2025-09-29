import argparse
import yaml
from PIL import Image, ImageDraw, ImageFont
import os
import textwrap

ASSETS_PATH = "assets"
FONTS_PATH = os.path.join(ASSETS_PATH, "fonts")
LOGOS_PATH = os.path.join(ASSETS_PATH, "logos")

MARGIN = 40
LINE_SPACING = 14
LOGO_MAX_SIZE = 150

NO_SPACING = 1

FONT_SIZES = {
    "title": 20,
    "content": 12,
}

def load_font(name, size):
    path = os.path.join(FONTS_PATH, name)
    try:
        return ImageFont.truetype(path, size)
    except Exception as e:
        print(f"⚠️ Failed to load font {path}: {e}")
        return ImageFont.load_default()

def wrap_text(text, font, max_width):
    lines = []
    for line in text.split('\n'):
        wrapped = textwrap.wrap(line, width=100)
        lines.extend(wrapped if wrapped else [''])
    return lines

def draw_centered_text(draw, text, y, font, image_width, no_spacing: int = 0):
    lines = wrap_text(text, font, image_width - 2 * MARGIN)
    for line in lines:
        bbox = font.getbbox(line)
        w = bbox[2] - bbox[0]
        h = bbox[3] - bbox[1]
        draw.text(((image_width - w) / 2, y), line, fill="black", font=font)
        y = y + h + LINE_SPACING
        if no_spacing == NO_SPACING:
            y = y - 5
    return y

def draw_centered_logo(image, logo_filename, max_width, y, no_spacing: int = 0):
    path = os.path.join(LOGOS_PATH, logo_filename)
    if not os.path.exists(path):
        print(f"⚠️ Logo not found: {path}")
        return y
    logo = Image.open(path).convert("RGBA")
    logo.thumbnail((max_width, max_width))
    x = (image.width - logo.width) // 2
    image.paste(logo, (x, y), logo)
    if no_spacing == NO_SPACING:
        return y + logo.height
    return y + logo.height + LINE_SPACING

def fill_content_to_image(draw, image, data, font_bold_name, font_regular_name, max_width):
    y = MARGIN
    image_width = image.width

    # Fonts
    company = data.get("company", {})
    company_font_size = company.get("font_size", FONT_SIZES["title"])
    font_company = load_font(font_bold_name, company_font_size)

    model = data.get("model", {})
    model_font_size = model.get("font_size", FONT_SIZES["content"])
    font_model = load_font(font_regular_name, model_font_size)

    font_code = load_font(font_regular_name, data.get("code_font_size", FONT_SIZES["content"]))
    font_text = load_font(font_regular_name, FONT_SIZES["content"])

    # Company
    company_name = company.get("name", "N/A")
    y = draw_centered_text(draw, company_name, y, font_company, image_width)

    # Model
    model_name = model.get("name", "")
    y = draw_centered_text(draw, f"MODEL: {model_name}", y, font_model, image_width)

    # Countries
    for country in data.get("countries", []):
        y += 10
        country_name = country.get("name", "")
        country_font_size = country.get("font_size", FONT_SIZES["title"])
        font_country = load_font(font_bold_name, country_font_size)
        y = draw_centered_text(draw, country_name, y, font_country, image_width)

        if "ices" in country:
            ices = country["ices"]
            y = draw_centered_text(draw, ices.get("standards", ""), y, font_text, image_width, NO_SPACING)
            y = draw_centered_text(draw, f"Contains IC: {ices.get('cavli_code', '')}", y, font_code, image_width, NO_SPACING)
            y = draw_centered_text(draw, f"IC: {ices.get('code', '')}", y, font_code, image_width)

        if "fcc" in country:
            fcc = country["fcc"]
            if "logo" in fcc:
                y = draw_centered_logo(image, fcc["logo"], max_width, y)
            y = draw_centered_text(draw, f"Contains FCC ID: {ices.get('cavli_code', '')}", y, font_code, image_width, NO_SPACING)
            y = draw_centered_text(draw, f"FCC ID: {fcc.get('code', '')}", y, font_code, image_width, NO_SPACING)
            if "statement" in fcc:
                y = draw_centered_logo(image, fcc["statement"], max_width, y)

        if "culus" in country:
            culus = country["culus"]
            if "logo" in culus:
                y = draw_centered_logo(image, culus["logo"], max_width, y, NO_SPACING)
            y = draw_centered_text(draw, f"{culus.get('code', '')}", y, font_code, image_width)

        y += 10
    return y + MARGIN

def generate_elabel_from_yaml(yaml_path, output_path, width):
    with open(yaml_path, "r") as f:
        data = yaml.safe_load(f)

    font_bold_name = data.get("font_bold", "DejaVuSans-Bold.ttf")
    font_regular_name = data.get("font_regular", "DejaVuSans.ttf")

    dummy_height = 5000
    dummy_image = Image.new("RGB", (width, dummy_height), "white")
    dummy_draw = ImageDraw.Draw(dummy_image)
    final_height = fill_content_to_image(dummy_draw, dummy_image, data, font_bold_name, font_regular_name, width)

    image = Image.new("RGB", (width, final_height), "white")
    draw = ImageDraw.Draw(image)
    fill_content_to_image(draw, image, data, font_bold_name, font_regular_name, width)

    image.save(output_path)
    print(f"✅ e-label saved to: {output_path}")

def main():
    parser = argparse.ArgumentParser(description="Generate regulatory e-label PNG from YAML")
    parser.add_argument("yaml_file", help="Path to YAML file")
    parser.add_argument("-o", "--output", default="elabel_output.png", help="Output PNG file")
    parser.add_argument("-w", "--width", type=int, default=1024, help="Width of PNG")
    args = parser.parse_args()

    generate_elabel_from_yaml(args.yaml_file, args.output, args.width)

if __name__ == "__main__":
    main()
