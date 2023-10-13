// C standard library
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <time.h>
#include <stdbool.h>

// OpenGL
#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>
#include <glad/glad.h>

// Local includes
#include "util.h"
#include "time.hpp"

// ----------------------------------------------------------------------------
const GLenum DRAW_MODE = GL_STATIC_DRAW;

void error(int32_t error, const char *description) {
    fprintf(stderr, "GLFW Error %d: %s\n", error, description);
}

void input(GLFWwindow *window) {
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS) {
        glfwSetWindowShouldClose(window, GL_TRUE);
    }
}

void resize(GLFWwindow *window, int32_t width, int32_t height) {
    (void) window;

    glViewport(0, 0, width, height);
}


void exit_if_gl_error(uint32_t shader, GLenum error_type, char *error_header) {
    int32_t success;
    char info_log[512];

    glGetShaderiv(shader, error_type, &success);
    if (success) {
        return;
    }

    glGetShaderInfoLog(shader, 512, NULL, info_log);
    fprintf(stderr, "%s %s\n", error_header, info_log);
    exit(EXIT_FAILURE);
}

static const char *const vertex_shader_source = 
"#version 330 core\n"
"layout (location = 0) in vec3 aPos;\n"
"void main() {\n"
"    gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);\n"
"}\n";

int32_t main(int32_t argc, const char *const argv[]) {

    if (argc != 2) {
        fprintf(stderr, "Expected 1 arguments, got %d\n", argc - 1);
        fprintf(stderr, "Usage: $ <program> path\\to\\fragment.glsl\n");
        exit(EXIT_SUCCESS);
    }

    const char *fragment_shader_source = read_file(argv[1]);

    if (!glfwInit()) {
        fprintf(stderr, "Failed to initialize GLFW\n");
        exit(EXIT_FAILURE);
    }

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    glfwSetErrorCallback(error);

    int width = 800;
    int height = 600;

    char *title = "Shader Playground";
    GLFWwindow *window = glfwCreateWindow(width, height, title, NULL, NULL);

    if (window == NULL) {
        fprintf(stderr, "Failed to create GLFW window\n");
        glfwTerminate();
        exit(EXIT_FAILURE);
    }

    glfwMakeContextCurrent(window);
    glfwSwapInterval(1);

    if (!gladLoadGLLoader((GLADloadproc) glfwGetProcAddress)) {
        fprintf(stderr, "Failed to initialize GLAD\n");
        exit(EXIT_FAILURE);
    }

    glViewport(0, 0, width, height);
    glfwSetFramebufferSizeCallback(window, resize);

    uint32_t vertex_shader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertex_shader, 1, &vertex_shader_source, NULL);
    glCompileShader(vertex_shader);

    char *error_header = "Error while compiling vertex shader";
    exit_if_gl_error(vertex_shader, GL_COMPILE_STATUS, error_header);

    uint32_t fragment_shader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragment_shader, 1, &fragment_shader_source, NULL);
    glCompileShader(fragment_shader);

    error_header = "Error while compiling fragment shader";
    exit_if_gl_error(fragment_shader, GL_COMPILE_STATUS, error_header);

    uint32_t shader = glCreateProgram();
    glAttachShader(shader, vertex_shader);
    glAttachShader(shader, fragment_shader);
    glLinkProgram(shader);

    error_header = "Error while linking shader program";
    exit_if_gl_error(fragment_shader, GL_LINK_STATUS, error_header);

    glDeleteShader(vertex_shader);
    glDeleteShader(fragment_shader);

    float vertices[] = {
         1.0f,  1.0f, 0.0f,  // top right
         1.0f, -1.0f, 0.0f,  // bottom right
        -1.0f, -1.0f, 0.0f,  // bottom left
        -1.0f,  1.0f, 0.0f   // top left 
    };

    uint32_t indices[] = {
        0, 1, 3,   // first triangle
        1, 2, 3    // second triangle
    }; 

    uint32_t vbo;
    glGenBuffers(1, &vbo);
    
    uint32_t ebo;
    glGenBuffers(1, &ebo);

    uint32_t vao;
    glGenVertexArrays(1, &vao);
    glBindVertexArray(vao);
    
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, DRAW_MODE);

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, DRAW_MODE);

    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), NULL);
    glEnableVertexAttribArray(0);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);

    uint64_t program_start_milis = get_milis();
    uint64_t program_time_milis = 0;
    uint64_t last_program_milis = program_start_milis;
    float program_time_secs = 0.0f;

    while(!glfwWindowShouldClose(window)) {

        // Update stuff
        
        input(window);

        program_time_milis = get_milis() - program_start_milis;
        program_time_secs = program_time_milis / 1000.0f;

        float delta_time = program_time_milis - last_program_milis;
        (void) delta_time;
        
        last_program_milis = program_time_milis;
        
        glfwGetFramebufferSize(window, &width, &height);

        char title[256];
        snprintf(title, 256, "Shader Playground - %dx%d %.2f ms", width, height, delta_time);
        glfwSetWindowTitle(window, title);


        // Clear stuff
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        // Draw stuff
        glUseProgram(shader);

        uint32_t iTime = glGetUniformLocation(shader, "iTime");
        glUniform1f(iTime, program_time_secs);

        uint32_t iResolution = glGetUniformLocation(shader, "iResolution");
        glUniform2i(iResolution, width, height);

        glBindVertexArray(vao);
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
        glBindVertexArray(0);
        
        // Push stuff
        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    glDeleteVertexArrays(1, &vao);
    glDeleteBuffers(1, &vbo);
    glDeleteProgram(shader);

    glfwDestroyWindow(window);
    glfwTerminate();

    exit(EXIT_SUCCESS);
}
