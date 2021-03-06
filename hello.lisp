;; Load required libraries.
(require :sdl2)
(require :cl-opengl)

(defglobal *rot* 0)

(defun debug-log (msg &rest args)
  "Output and flush MSG to STDOUT with arguments ARGS"
  (apply #'format t msg args)
  ;; Flush to standard out
  (finish-output))
 
(defun main ()
  "The entry point of our game."
  (sdl2:with-init (:everything)
    (debug-log "Using SDL library version: ~D.~D.~D~%"
               sdl2-ffi:+sdl-major-version+
               sdl2-ffi:+sdl-minor-version+
               sdl2-ffi:+sdl-patchlevel+)
 
    (sdl2:with-window (win :flags '(:shown :opengl))
      (sdl2:with-gl-context (gl-context win)
        ;; Basic window/gl setup
        (setup-gl win gl-context)
        ;; Run main loop
        (main-loop win 'render)))))

(defun setup-gl (win gl-context)
  "Setup OpenGL with the window WIN and the gl context of GL-CONTEXT"
  (debug-log "Setting up window/gl.~%")
  (sdl2:gl-make-current win gl-context)
  (gl:viewport 0 0 800 600)
  (gl:matrix-mode :projection)
  (gl:ortho 0 800 0 600 -2 2)
  (gl:matrix-mode :modelview)
  (gl:load-identity)
  ;; Clear to black
  (gl:clear-color 0.0 0.0 0.0 1.0))
 
(defun render ()
  (setq *rot* (+ *rot* 0.3))
  (gl:clear :color-buffer)

  ;; Transform
  (gl:load-identity)
  (gl:translate 400 300 0)
  (gl:rotate *rot* 0 0 1)

  ;; Draw a demo triangle
  (gl:begin :triangles)
  (gl:color 1.0 0.3 0.6)
  (gl:vertex 0.0 200.0)
  (gl:color 1.0 1.0 0.0)
  (gl:vertex -200.0 -100.0)
  (gl:color 0.3 1.0 1.0)
  (gl:vertex 200.0 -100.0)
  (gl:end)
  (gl:flush))
 
(defun main-loop (win render-fn)
  "Run the game loop that handles input, rendering through the
  render function RENDER-FN, amongst others."
  (sdl2:with-event-loop (:method :poll)
    (:keydown (:keysym keysym)
              (when (sdl2:scancode= (sdl2:scancode-value keysym) :scancode-escape)
                (sdl2:push-event :quit)))
    (:idle ()
           (funcall render-fn)
           ;; Swap back buffer
           (sdl2:gl-swap-window win))
    (:quit () t)))
