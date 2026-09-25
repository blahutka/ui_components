import { Controller } from "@hotwired/stimulus"

// Behaviour for Blocks::MusicPlayer: play / pause, the seek bar, previous / next and the time
// labels. With an <audio> target it drives the audio; without, it advances the time once a
// second (a demo). At the end of the track it loops while Repeat is pressed, else it stops.
//
// Emits `blocks--music-player:play`, `:pause`, `:previous`, `:next` and `:seek` with { position }.
export default class extends Controller {
  static targets = [ "audio", "slider", "elapsed", "remaining", "play", "repeat" ]
  static values = { duration: Number, position: Number, playing: Boolean, playLabel: String, pauseLabel: String }

  connect() {
    if (this.hasAudioTarget) {
      this.onTime = () => this.update(this.audioTarget.currentTime, { fromAudio: true })
      this.onEnded = () => this.finish()
      this.audioTarget.addEventListener("timeupdate", this.onTime)
      this.audioTarget.addEventListener("ended", this.onEnded)
    }
    if (this.playingValue) this.start()
  }

  disconnect() {
    this.stop()
    this.audioTarget?.removeEventListener("timeupdate", this.onTime)
    this.audioTarget?.removeEventListener("ended", this.onEnded)
  }

  // Actions

  toggle({ detail: { pressed } }) {
    pressed ? this.start() : this.stop()
    this.dispatch(pressed ? "play" : "pause")
  }

  seek({ target, detail: { value } }) {
    if (target !== this.sliderTarget) return

    this.update(value, { fromSlider: true })
    if (this.hasAudioTarget) this.audioTarget.currentTime = value
    this.dispatch("seek", { detail: { position: value } })
  }

  previous() {
    this.jump(0)
    this.dispatch("previous")
  }

  next() {
    this.jump(0)
    this.dispatch("next")
  }

  // Playback

  start() {
    this.setPlaying(true)
    if (this.hasAudioTarget) {
      this.audioTarget.play().catch(() => this.setPlaying(false))
    } else {
      clearInterval(this.timer)
      this.timer = setInterval(() => this.tick(), 1000)
    }
  }

  stop() {
    this.setPlaying(false)
    clearInterval(this.timer)
    if (this.hasAudioTarget) this.audioTarget.pause()
  }

  tick() {
    if (this.sliderTarget.hasAttribute("data-dragging")) return
    this.positionValue + 1 >= this.durationValue ? this.finish() : this.update(this.positionValue + 1)
  }

  finish() {
    if (this.hasRepeatTarget && this.repeatTarget.getAttribute("aria-pressed") === "true") {
      this.jump(0)
      if (this.hasAudioTarget) this.audioTarget.play()
    } else {
      this.update(this.durationValue)
      this.stop()
    }
  }

  jump(position) {
    this.update(position)
    if (this.hasAudioTarget) this.audioTarget.currentTime = position
  }

  // Position, time labels and the seek bar

  update(position, { fromSlider = false } = {}) {
    this.positionValue = Math.max(0, Math.min(this.durationValue, Math.round(position)))
    this.elapsedTarget.textContent = this.clock(this.positionValue)
    this.remainingTarget.textContent = this.clock(this.durationValue - this.positionValue)
    if (!fromSlider) this.moveSlider(this.positionValue)
  }

  moveSlider(position) {
    const input = this.sliderTarget.querySelector("input[type=range]")
    const slider = this.application.getControllerForElementAndIdentifier(this.sliderTarget, "ui--slider")
    if (!input || !slider) return

    input.value = position
    slider.render()
  }

  setPlaying(playing) {
    this.playingValue = playing
    const button = this.playTarget
    button.setAttribute("aria-pressed", playing)
    button.toggleAttribute("data-pressed", playing)
    button.setAttribute("aria-label", playing ? this.pauseLabelValue : this.playLabelValue)
  }

  clock(seconds) {
    const hours = Math.floor(seconds / 3600)
    const minutes = Math.floor((seconds % 3600) / 60)
    const secs = String(Math.floor(seconds % 60)).padStart(2, "0")
    return hours > 0 ? `${hours}:${String(minutes).padStart(2, "0")}:${secs}` : `${minutes}:${secs}`
  }
}
