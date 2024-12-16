/*
 * This file is part of ***  M y C o R e  ***
 * See https://www.mycore.de/ for details.
 *
 * MyCoRe is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * MyCoRe is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with MyCoRe.  If not, see <http://www.gnu.org/licenses/>.
 */

import $ from 'jquery';
import 'bootstrap';

export abstract class MIRModalHandler {
  private _isBusy = false;
  private _modalDiv: HTMLDivElement;

  constructor(
    modalDiv: HTMLDivElement,
  ) {
    this._modalDiv = modalDiv;
    this.handleOpenModal = this.handleOpenModal.bind(this);
    this.bindEvents();
  }

  protected get isBusy(): boolean {
    return this._isBusy;
  }

  protected set isBusy(isBusy: boolean) {
    this._isBusy = isBusy;
  }

  protected get modalDiv(): HTMLDivElement {
    return this.modalDiv;
  }

  protected bindEvents(): void {
    $(this._modalDiv).on('hide.bs.modal', this.handleClose);
    $(this._modalDiv).on('show.bs.modal', this.handleOpenModal);
  }

  private handleClose(event: JQuery.TriggeredEvent) {
    if (this.isBusy) {
      event.preventDefault();
    }
  }

  public showModal() {
    $(this._modalDiv).modal('show');
  }

  public closeModal() {
    $(this._modalDiv).modal('hide');
  }

  protected abstract handleOpenModal (event: JQuery.TriggeredEvent): void;
}
