shader_type canvas_item;

void fragment(){
  COLOR = texture(TEXTURE, UV); // Read from texture again.
  //COLOR.b = UV.x; //set blue channel to 1.0
}