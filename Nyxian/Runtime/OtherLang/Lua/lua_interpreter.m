//
//
// Created by Anonym on 01.12.24
//

// lua
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

#import <unistd.h>

#import <bridge.h>

int o_lua(NSString *path) {
    // Save the current working directory
    char original_dir[FILENAME_MAX];
    if (getcwd(original_dir, sizeof(original_dir)) == NULL) {
        perror("Failed to get current directory");
        return 1;
    }

    // Extract the directory containing the Lua script
    NSString *directory = [path stringByDeletingLastPathComponent];

    // Change the current working directory to the script's directory
    if (chdir([directory UTF8String]) != 0) {
        perror("Failed to change directory");
        return 1;
    }

    // Create a new Lua state
    lua_State *L = luaL_newstate();

    // Load Lua standard libraries
    luaL_openlibs(L);

    // Load and execute the Lua script from the file
    if (luaL_dofile(L, [path UTF8String]) != LUA_OK) {
        fprintf(stderr, "Error running Lua script: %s\n", lua_tostring(L, -1));
        lua_close(L);

        // Restore the original working directory before returning
        if (chdir(original_dir) != 0) {
            perror("Failed to restore directory");
        }

        return 1;
    }

    // Close the Lua state
    lua_close(L);

    // Restore the original working directory
    if (chdir(original_dir) != 0) {
        perror("Failed to restore directory");
        return 1;
    }

    return 0;
}

jmp_buf LuaExitBuf;
int luaexit(lua_State *L) {
    longjmp(LuaExitBuf, 1);
}

int o_lua_repl(NSString *path) {
    // Save the current working directory
    char original_dir[FILENAME_MAX];
    if (getcwd(original_dir, sizeof(original_dir)) == NULL) {
        perror("Failed to get current directory");
        return 1;
    }

    // Change the current working directory to the script's directory
    if (chdir([path UTF8String]) != 0) {
        perror("Failed to change directory");
        return 1;
    }

    // Create a new Lua state
    lua_State *L = luaL_newstate();

    // Load Lua standard libraries
    luaL_openlibs(L);

    if(setjmp(LuaExitBuf))
    {
        if (chdir(original_dir) != 0) {
            perror("Failed to restore directory");
            return 1;
        }
        
        lua_close(L);
        return 0;
    }
    
    lua_register(L, "exit", luaexit);
    
    // Load Version
    printf("%s\n", LUA_COPYRIGHT);
    
    // Load and execute the Lua script from the file
    void doREPL (lua_State *L);
    doREPL(L);

    // Close the Lua state
    lua_close(L);

    // Restore the original working directory
    if (chdir(original_dir) != 0) {
        perror("Failed to restore directory");
        return 1;
    }

    return 0;
}
