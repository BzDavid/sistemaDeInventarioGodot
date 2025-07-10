extends InventoryData
class_name InventoryDataEquip
# codigo para el equipo

func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	# van solamente elementos tipo de equipamiento
	if not grabbed_slot_data.item_data is ItemDataEquip:
		return grabbed_slot_data
	
	# llama a la clase principal 
	return super.drop_slot_data(grabbed_slot_data, index)
	
	# solamente cuando haya un item en el piso que sea tipo equipamiento,
	# va hacia el slot del equipamiento
func drop_single_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	# van solamente elementos tipo de equipamiento
	if not grabbed_slot_data.item_data is ItemDataEquip:
		return grabbed_slot_data
	
	# llama a la clase principal 
	return super.drop_single_slot_data(grabbed_slot_data, index)
