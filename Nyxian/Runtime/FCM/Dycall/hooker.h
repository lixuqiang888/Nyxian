//
// hooker.h
// libdycall
//
// Created by SeanIsNotAConstant on 15.10.24
//

#ifndef HOOKER_H
#define HOOKER_H

/**
 * @brief Set up the hooks
 *
 * This function hooks certain symbols like exit and atexit to make a dylib behave like a binariy
 * For example instead of calling real exit it would call our own implementation of it
 */
int hooker(const char *path, void *dylib);

#endif // HOOKER_H
