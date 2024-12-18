-- fixme deprecate
local networking = {}

function networking.sendMessage(targetId, messageType, payload)
	local message = {
		type = messageType,
		payload = payload,
	}
	rednet.send(targetId, textutils.serialize(message))
end

function networking.receiveMessage()
	local senderId, rawMessage = rednet.receive()
	local success, message = pcall(textutils.unserialize, rawMessage)
	if success and message then
		return senderId, message.type, message.payload
	else
		return senderId, nil, nil
	end
end

return networking
