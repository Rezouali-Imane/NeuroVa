import { TimerRepository } from "../../interfaces/repositories/TimerRepository.js";

import type { DeleteTimerDTO } from "../../interfaces/dtos/Timer.dto.js";

export const DeleteTimer = async (data: DeleteTimerDTO) => {
  if (!data.timerid) {
    throw new Error("Timer ID is required.");
  }

  const timer = await TimerRepository.findById(data.timerid);
  if (!timer) {
    throw new Error("Timer not found.");
  }

  return await TimerRepository.delete(data.timerid);
};
