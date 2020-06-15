#include "LegacyWorldLoader.h"

#include <File.hpp>
#include <OS.hpp>

using namespace godot;

void LegacyWorldLoader::_register_methods()
{
    register_method("loadLevelFromFilesystem", &LegacyWorldLoader::loadLevelFromFilesystem);
    register_method("loadLevelFromLocalhost", &LegacyWorldLoader::loadLevelFromLocalhost);
    register_method("loadLevelFromString", &LegacyWorldLoader::loadLevelFromString);
    register_method("_ready", &LegacyWorldLoader::_ready);

    register_property<LegacyWorldLoader, NodePath>("Loader", &LegacyWorldLoader::loaderNode, NodePath());
    //register_property<GDTest, String>("data", &GDTest::set_data, &GDTest::get_data, String("Hello world"));
}

void LegacyWorldLoader::_init()
{}

void LegacyWorldLoader::_ready()
{
    client.instance();
}


void LegacyWorldLoader::loadLevelFromFilesystem ( godot::String fileName )
{
    Node* worldAPI = get_node(loaderNode);
    
    Ref<File> gameFile;
    gameFile.instance();
    
    if (gameFile->file_exists(fileName)) {
        
        Godot::print("Found " + fileName);
    } else {
        Godot::print("Not found");
        return;
    }
    gameFile->open(fileName, File::ModeFlags::READ);
    LegacyLevel cyLevel;
    cyLevel.parseLevelCode(gameFile->get_as_text(), worldAPI);
    gameFile->close();
}

void godot::LegacyWorldLoader::loadLevelFromString(String levelContents)
{
    Node* worldAPI = get_node(loaderNode);
    
    LegacyLevel cyLevel;
    cyLevel.parseLevelCode(levelContents, worldAPI);
}

void godot::LegacyWorldLoader::loadLevelFromLocalhost(int gameNumber) 
{
    // For polling the server at intervals
    OS* os = OS::get_singleton(); 
    
    // Connect to host
    Error err = client->connect_to_host("localhost", 80);
    if (err != Error::OK) {
        Godot::print("Error connecting to localhost");
        return;
    }
    
    // TODO: Make this async
    while (client->get_status() == HTTPClient::Status::STATUS_CONNECTING || 
        client->get_status() == HTTPClient::Status::STATUS_RESOLVING) {
        client->poll();
        os->delay_msec(500);
    }
    
    if (client->get_status() != HTTPClient::Status::STATUS_CONNECTED) {
        Godot::print("Couldn't connect to localhost");
        return;
    }
    
    Godot::print("Connected!");
    
    // Request maze file
    String fileName = String("/getMaze.php?maze=" + String::num(gameNumber));
    Godot::print("Accessing " + fileName);
    PoolStringArray headers;
    headers.append("User-Agent: Pirulo/1.0 (Godot)");
    headers.append("Accept: */*");
    if (client->request(HTTPClient::Method::METHOD_GET, fileName, headers) != Error::OK) {
        Godot::print("Error requesting maze file");
        return;
    }
    
    while (client->get_status() == HTTPClient::Status::STATUS_REQUESTING) {
        client->poll();
        os->delay_msec(500);
    }
    
    if (client->has_response()) {
        Godot::print("Returned with code: " + String::num_int64(client->get_response_code()));
        if (client->get_response_code() == HTTPClient::ResponseCode::RESPONSE_OK) {
            Godot::print("Response size: " + String::num_int64(client->get_response_body_length()));
        } else {
            return;
        }
    }
    
    PoolByteArray rawResponse;
    while (client->get_status() == HTTPClient::Status::STATUS_BODY) {
        client->poll();
        PoolByteArray responseChunk = client->read_response_body_chunk();
        if (responseChunk.size() == 0) {
            os->delay_msec(500);
        } else {
            rawResponse.append_array(responseChunk);
        }
    }
    
    Godot::print("Bytes received: " + String::num_int64(rawResponse.size()));
    String data = String((char *)(rawResponse.read().ptr()));
    
    LegacyLevel cyLevel;
    Node* worldAPI = get_node(loaderNode);
    cyLevel.parseLevelCode(data, worldAPI);
}
