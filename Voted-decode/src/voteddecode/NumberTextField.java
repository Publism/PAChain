package voteddecode;

import javafx.scene.control.IndexRange;
import javafx.scene.control.TextField;

public class NumberTextField extends TextField {
    @Override
    public void replaceText(IndexRange range, String text) {
        if(validate(text)) {
            super.replaceText(range, text);
        }
    }

    @Override
    public void replaceText(int start, int end, String text) {
        if(validate(text)) {
            super.replaceText(start, end, text);
        }
    }

    @Override
    public void replaceSelection(String replacement) {
        if(validate(replacement)) {
            super.replaceSelection(replacement);
        }
    }

    private boolean validate(String text)
    {
        return text.matches("[0-9]*");
    }
}
